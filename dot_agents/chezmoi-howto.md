# Chezmoi Usage Patterns & Gotchas

**Last Updated:** 2025-12-15

This document contains non-obvious usage patterns and common pitfalls discovered while using chezmoi for dotfiles management.

---

## 🔐 Encryption

### Common Mistake: `chezmoi encrypt` vs `chezmoi add --encrypt`

**❌ WRONG - This hangs waiting for stdin:**
```shell
chezmoi encrypt  # Waits for you to type/pipe data - NOT what you want!
```

**✅ CORRECT - Add encrypted files:**
```shell
chezmoi add --encrypt ~/.gmailctl/config.personal.jsonnet
```

**Explanation:**
- `chezmoi encrypt` is a low-level utility that reads from stdin and outputs encrypted data to stdout
- `chezmoi add --encrypt` is what you want - it adds a file to chezmoi's source directory in encrypted form
- Encrypted files are stored as `encrypted_*.age` in the source directory
- They're committed to git (encrypted) and auto-decrypted when you run `chezmoi apply`

### Security Model

**What's stored where:**
- Private key: `~/.config/chezmoi/key.txt` (NEVER commit, copy securely to new machines)
- Public key: In `~/.config/chezmoi/chezmoi.toml` (safe to commit)
- Encrypted files: `~/.local/share/chezmoi/encrypted_*.age` (safe to commit)

**Equivalent to yadm:**
- yadm stores encrypted archive in git: `.local/share/yadm/archive`
- chezmoi stores encrypted files in git: `encrypted_*.age`
- Both expose encrypted blobs in public repos - same security profile

---

## 🔗 Symlinks

### Templated Symlinks

Symlinks can be templated to point to different targets per machine:

**File:** `symlink_dot_gmailctl/config.jsonnet.tmpl`
```
./config.{{ if hasKey . "gmailctl_config" }}{{ .gmailctl_config }}{{ else }}personal{{ end }}.jsonnet
```

**Default behavior (no config):**
- Symlink points to: `./config.personal.jsonnet`

**Work machine (`~/.config/chezmoi/chezmoi.toml`):**
```toml
[data]
    gmailctl_config = "work"
```
- Symlink points to: `./config.work.jsonnet`

### `create_` Doesn't Work with Symlinks

**Tested and confirmed:**
```shell
chezmoi add --create ~/test_symlink
# Creates: symlink_test_symlink (no create_ prefix)
# The --create flag is silently ignored for symlinks
```

Use templating instead for conditional symlink behavior.

---

## 📝 create_ vs Normal Files

### Normal File Behavior
```shell
chezmoi add ~/.bashrc
# Creates: dot_bashrc
```

When you run `chezmoi apply`:
- Compares file contents with source
- If different → **Prompts**: "file has changed, overwrite?"
- Requires user decision on every conflict

### create_ File Behavior
```shell
chezmoi add --create ~/.bashrc
# Creates: create_dot_bashrc
```

When you run `chezmoi apply`:
- Checks: "Does file exist?"
  - **If NO** → Creates it with source content
  - **If YES** → **Skips entirely**, never prompts, never checks content
- Perfect for "default files that can be customized per-machine"

### Restoring create_ Files

If you delete a `create_` file and want it back:
```shell
chezmoi apply --force ~/path/to/file
# Recreates the file from source
```

---

## 🎯 Interactive Prompts

### The Mysterious "has changed" Prompt

When `chezmoi apply` says:
```
.gmailctl/config.personal.jsonnet has changed since chezmoi last wrote it?
```

**Valid responses** (type these and press Enter):
- `diff` or `d` - Show differences
- `overwrite` or `o` - Replace local file with chezmoi's version
- `all-overwrite` - Overwrite this and all other conflicts
- `skip` or `s` - Keep local file unchanged
- `quit` or `q` - Stop applying

**Common mistakes:**
- ❌ Pressing `y`/`n` - Not valid responses
- ❌ Just pressing Enter - Won't work
- ❌ Expecting `[y/n]` prompt - Chezmoi doesn't use that pattern

**Better alternatives:**
```shell
chezmoi diff                    # Preview changes first
chezmoi apply --force           # Skip all prompts, trust chezmoi
chezmoi merge ~/.bashrc         # Use merge tool for conflicts
```

### TTY Errors

Error: `could not open a new TTY: open /dev/tty: no such device or address`

**Cause:** Chezmoi tries to prompt interactively but there's no TTY (common in CI, scripts, or some terminal emulators)

**Solutions:**
```shell
chezmoi apply --force           # Skip all prompts
chezmoi apply --no-tty          # Don't attempt TTY prompts
```

---

## 📦 Templates

### Default Values and Missing Keys

**❌ WRONG - `default` filter doesn't work with missing keys:**
```
{{ .some_key | default "fallback" }}
# Error: map has no entry for key "some_key"
```

**✅ CORRECT - Use `hasKey` check:**
```
{{ if hasKey . "some_key" }}{{ .some_key }}{{ else }}fallback{{ end }}
```

**Why:**
- Chezmoi's template engine errors on missing keys before filters are applied
- Always use `hasKey` to check existence first
- This is different from some other template systems

### Common Template Patterns

**Machine-specific values:**
```toml
# ~/.config/chezmoi/chezmoi.toml
[data]
    vcs_author_email = "work@example.com"
    gmailctl_config = "work"
```

**Fallback to command output:**
```
{{ if hasKey . "vcs_author_email" }}{{ .vcs_author_email }}{{ else }}{{ output "git" "config" "user.email" | trim }}{{ end }}
```

---

## 🚫 .chezmoiignore

### Ignore Patterns

**File:** `.chezmoiignore`
```
# Ignore yadm-specific files
.config/yadm/

# Ignore local/session files
AGENTS.local.md
SESSION_NOTES.md
```

**Important:**
- `.chezmoiignore` prevents chezmoi from managing files in your home directory
- Patterns apply to destination paths (in `~`), not source paths
- If you ignore a file, `chezmoi add` will warn and skip it
- Use this for machine-specific files or files managed by other tools

---

## 🔄 Workflow Tips

### Testing Changes Safely

```shell
# 1. Preview what would change
chezmoi diff

# 2. Dry-run (shows actions, doesn't execute)
chezmoi apply --dry-run --verbose

# 3. Apply to specific file first
chezmoi apply ~/.bashrc

# 4. Apply everything
chezmoi apply
```

### Updating Source from Local Changes

```shell
# After editing ~/.bashrc directly:
chezmoi add ~/.bashrc          # Update source with local changes
chezmoi re-add                 # Re-add all managed files

# Or edit through chezmoi:
chezmoi edit ~/.bashrc         # Edit source file
chezmoi edit --apply ~/.bashrc # Edit source and apply on exit
chezmoi edit --watch ~/.bashrc # Edit source and auto-apply on save
```

**Note:** `chezmoi add` is recursive by default for directories. Use `--recursive=false` to add only the directory itself.

### Syncing Permissions from Destination to Source

When you have permission diffs and want chezmoi to adopt your local permissions:

**For files:**

```shell
chezmoi add --force ~/.some-file
# Reads current permissions and updates source entry (executable_, private_, readonly_ attributes)
```

**For directories or when you only want to fix permissions (not content):**

Use `chattr` with the appropriate attribute flags. Common permission diff patterns:

```shell
# Directory permission examples:
chezmoi chattr -- -p ~/.ssh                    # 40700 -> 40755: Directory went from private to public
chezmoi chattr +p ~/.ssh                       # 40755 -> 40700: Directory went from public to private

# File permission examples:
chezmoi chattr +x ~/.local/bin/script.sh      # 0644 -> 0755: File gained execute bit
chezmoi chattr -- -x ~/.local/bin/script.sh    # 0755 -> 0644: File lost execute bit
chezmoi chattr +p ~/.config/some-secret        # 0644 -> 0600: File became private
chezmoi chattr -- -p ~/.config/some-file       # 0600 -> 0644: File became public
chezmoi chattr +r ~/.config/read-only.conf     # 0644 -> 0444: File became readonly
chezmoi chattr -- -r ~/.config/now-writable.conf # 0444 -> 0644: File became writable
```

**Permission attribute quick reference:**

- `+x` / `-x` = executable bit (0755/0700 vs 0644/0600)
- `+p` / `-p` = private (0700/0600 vs 0755/0644)
- `+r` / `-r` = readonly (0444/0400 vs 0644/0600)

### Common Operations

```shell
# Check what chezmoi manages
chezmoi managed

# See what files would be created/updated
chezmoi status

# Verify configuration
chezmoi doctor

# View file from source without applying
chezmoi cat ~/.bashrc

# Remove file from chezmoi management
chezmoi forget ~/.bashrc
```

---

## 🏗️ Repository Structure

### Where Things Live

```
~/.local/share/chezmoi/          # Source directory (git repo)
├── dot_bashrc                   # Regular file
├── create_dot_profile.local     # Created once, never updated
├── dot_gitconfig.d/
│   └── user.conf.tmpl          # Template file
├── encrypted_private_*.age      # Encrypted file
├── symlink_dot_config/          # Directory with symlinks
│   └── some-link.tmpl          # Templated symlink target
└── .chezmoiignore              # Ignore patterns

~/.config/chezmoi/
├── chezmoi.toml                # Config file (with encryption settings)
└── key.txt                     # Age private key (NEVER commit!)

~/                              # Destination directory
├── .bashrc                     # Applied from dot_bashrc
├── .profile.local              # Created from create_dot_profile.local
└── .config/some-link           # Symlink from symlink_dot_config/some-link.tmpl
```

### Git Remote Setup

Chezmoi source directory is a git repo:
```shell
cd ~/.local/share/chezmoi
git remote -v
# Should point to: git@github.com:username/dotfiles.git

# If it points to local path (like ~/.dotfiles), fix it:
git remote set-url origin git@github.com:username/dotfiles.git
```

---

## 🐛 Common Issues

### Issue: Encrypted files ignored

**Symptom:**
```
chezmoi add --encrypt ~/.gmailctl/config.jsonnet
# Output: chezmoi: warning: ignoring .gmailctl/config.jsonnet
```

**Cause:** File is in `.chezmoiignore`

**Fix:** Remove from `.chezmoiignore` or use more specific patterns

### Issue: Template syntax errors on apply

**Symptom:**
```
template: dot_file.tmpl:1:12: map has no entry for key "some_key"
```

**Cause:** Missing key in chezmoi data, and template doesn't handle it

**Fix:** Use `hasKey` checks in templates (see Templates section above)

### Issue: Symlinks become regular files

**Symptom:** Symlink in home directory becomes a regular file after `chezmoi apply`

**Cause:** Used `add` instead of recognizing it as a symlink

**Fix:**
```shell
chezmoi forget ~/.config/some-link
rm ~/.config/some-link
# Re-create symlink manually
chezmoi add ~/.config/some-link  # Now detected as symlink
```

---

## 📚 References

### Official Documentation

- [Official chezmoi documentation](https://www.chezmoi.io/)
- [Target types reference](https://www.chezmoi.io/reference/target-types/)
- [Template reference](https://www.chezmoi.io/user-guide/templating/)
- [Manage different file types](https://www.chezmoi.io/user-guide/manage-different-types-of-file/)

### Upstream Docs on GitHub

For detailed command reference and workflows, see the upstream docs:

- [User guide](https://github.com/twpayne/chezmoi/tree/master/assets/chezmoi.io/docs/user-guide)
- [Daily operations](https://github.com/twpayne/chezmoi/tree/master/assets/chezmoi.io/docs/user-guide/daily-operations.md)
- [Command overview](https://github.com/twpayne/chezmoi/tree/master/assets/chezmoi.io/docs/user-guide/command-overview.md)
- [Manage different types of file](https://github.com/twpayne/chezmoi/tree/master/assets/chezmoi.io/docs/user-guide/manage-different-types-of-file.md)
