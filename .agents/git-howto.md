# Git + yadm + Worktree Workflows

**When to read this:** Working with the dotfiles repository which has a yadm+jj worktree setup.

---

## Core Concepts

### The Two-Location Setup

Your dotfiles have two working locations that share one git repository:

```
$HOME (~/‌)              ← yadm's working directory (main checkout)
~/.dotfiles/            ← jj worktree (for staging changes)

Both point to: ~/.local/share/yadm/repo.git
```

**Key insight:** They share the same git object database but have **separate indexes** (staging areas) and can point to different commits.

### Why This Matters

When you move bookmarks in the worktree (jj), you're changing what commit a branch points to. But yadm's working directory files (`$HOME`) don't automatically update. This creates a mismatch that shows up in `yadm status` as staged changes.

**Example:**
```shell
# Initial state
~/.dotfiles/.profile    (HEAD: commit A)
~/.profile              (HEAD: commit A)  ✅ In sync

# Edit in worktree, commit via jj
~/.dotfiles/.profile    (edited, new content)
jj describe -m "Add editor config"
jj bookmark set main    # ❌ DON'T DO THIS - moves main to new commit

# Now yadm sees:
~/.profile              (still has old content from commit A)
main branch HEAD        (points to commit B with new content)
yadm index              (shows removal of new content as "staged")
```

---

## The Golden Rule: Never Move `main` in the Worktree

**CRITICAL:** Do NOT use `jj bookmark set main` to advance main in `~/.dotfiles/`.

**Why:** yadm has main checked out in `$HOME`. Moving main out from under yadm creates a confusing state where yadm shows "staged changes" that are actually just the diff between the old working directory and new HEAD.

**Protection:** The worktree has `immutable_heads()` configured to include `main`, which prevents rewriting commits on main but doesn't prevent moving the bookmark itself. You must manually avoid `jj bookmark set main`.

---

## The Correct Workflow: Merge by SHA

### For Simple Changes (Recommended)

**Edit directly in `$HOME` and commit with yadm:**

```shell
# Edit the file
vim ~/.profile

# Test it
. ~/.profile

# Commit with yadm
yadm add .profile
yadm commit -m "🔧 Configure EDITOR to prefer helix"
yadm push
```

**When to use:** Single-file changes, quick fixes, isolated edits.

### For Multi-File Staged Changes

**Use the worktree and merge by SHA:**

```shell
# 1. Work in the worktree
cd ~/.dotfiles/
vim .profile .bashrc .gitconfig

# 2. Commit changes
jj describe -m "🔧 Configure shell and editor preferences"

# 3. Get the commit SHA
WORKTREE_SHA=$(jj log -r @ -T commit_id --no-graph)

# 4. Let yadm merge the changes by SHA
cd ~  # or anywhere outside ~/.dotfiles/
yadm status  # Should show clean
yadm merge $WORKTREE_SHA --ff-only

# 5. Verify and push
yadm status  # Should show "ahead of origin" but clean working directory
yadm push
```

**Why this works:**
- Git can merge commits by SHA directly, no bookmark needed
- yadm can fast-forward merge to incorporate your changes
- The working directory (`$HOME`) updates cleanly via the merge
- No temporary bookmarks to create and clean up

**When to use:** Multi-file changes, complex refactoring, related edits that should be tested together.

---

## How `yadm status` Works

After moving a bookmark in the worktree, `yadm status` may show confusing "staged changes":

```shell
cd ~/.dotfiles
jj bookmark set main    # ❌ Moved main to new commit

# Now yadm shows:
yadm status
# Changes to be committed:
#   modified:   .profile
```

**What this means:**
- Git's index (staging area) automatically reflects the current HEAD
- When HEAD moves (because main bookmark moved), the index updates
- But the working directory files (`~/.profile`) still have old content
- Git shows this as "the working directory would commit a revert of the new changes"

**It's NOT that:**
- Git auto-staged anything
- yadm did something special
- Some tool ran `yadm add`

**It's just:** The standard git behavior when HEAD changes but working directory doesn't.

---

## Fixing a Moved-Main Situation

If you accidentally moved main in the worktree:

### Option 1: Merge by SHA (Recommended)

```shell
cd ~/.dotfiles/

# 1. Get SHA of the changes you want to keep
YOUR_SHA=$(jj log -r @ -T commit_id --no-graph)

# 2. Move main back to origin
jj bookmark set main -r main@origin --allow-backwards

# 3. Merge via yadm using the SHA
yadm merge $YOUR_SHA --ff-only
```

### Option 2: Manual sync (If you know what you're doing)

```shell
cd ~

# Verify what yadm would do
yadm status
yadm diff .profile  # etc for each file

# If diffs look correct (adding your changes), reset and checkout
yadm reset HEAD .profile
yadm checkout -- .profile

# Verify
yadm status  # Should be clean
```

---

## Quick Decision Tree

**Before editing a file, ask:**

**Q: Should I edit in `~/.dotfiles/` or `$HOME`?**
- **Multi-file/complex changes** → Use `~/.dotfiles/` (recommended - better history tools)
- **Quick single-file fix** → Use `$HOME` (simpler - no merge step)
- **Already working in one location** → Continue there (don't switch mid-session)

**Q: Which command do I use to advance changes to main?**
- In worktree: **NEVER use `jj bookmark set main`** - get SHA and merge instead
- In $HOME: `yadm merge $WORKTREE_SHA --ff-only` or `yadm commit` directly

---

## worktree Configuration

The worktree has these special settings in `.jj/repo/config.toml`:

```toml
[revset-aliases]
"trunk()" = "main@origin"
"immutable_heads()" = "main | builtin_immutable_heads()"
```

**What this does:**
- Makes commits on `main` branch immutable (can't rewrite them)
- Prevents `jj squash`, `jj describe` on main commits
- Does NOT prevent moving the `main` bookmark (you must avoid this manually)

---

## Common Mistakes to Avoid

❌ **Moving main in worktree:**
```shell
cd ~/.dotfiles/
jj bookmark set main  # DON'T DO THIS
```

❌ **Editing both locations:**
```shell
vim ~/.dotfiles/.profile  # Edit in worktree
vim ~/.profile           # Also edit in $HOME
# Now you have conflicts to manually resolve
```

❌ **Using dynamic file queries in check scripts:**
```shell
# In check_this_branch.sh
CHECK_FILES=$(jj diff --name-only)  # DON'T - overcomplicated
```

✅ **Correct patterns:**
```shell
# Pick ONE location to edit
cd ~/.dotfiles/ && vim .profile  # OR
vim ~/.profile  # But not both

# Use _worktree bookmark
jj bookmark set _worktree
yadm merge _worktree --ff-only

# Use static file lists in check scripts
CHECK_FILES=".profile .bashrc .gitconfig"
```

---

## See Also

- `.agents/rules/branch-metadata.md` - How to use THIS_BRANCH.md and check_this_branch.sh
- `AGENTS.dotfiles.md` - Complete dotfiles repository workflow guide
- `README.md` - User-facing dotfiles setup documentation
