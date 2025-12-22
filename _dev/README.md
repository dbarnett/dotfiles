# Development Scripts

These scripts are in `_dev/` and excluded from deployment via `.chezmoiignore`.

## Pre-commit Checks

### check_templates.sh
Validates that all chezmoi templates have no hard data dependencies.

**Usage:**
```shell
./_dev/check_templates.sh
```

**What it checks:**
- Templates can render with empty data (simulates fresh machine)
- Uses safe patterns: `{{ or (index . "key") "default" }}` or `{{ if hasKey . "key" }}`
- Skips `create_` files (only created once)

### check_sensitive_strings.sh
Checks for sensitive content that shouldn't be in public commits.

**Usage:**
```shell
./_dev/check_sensitive_strings.sh
```

**Configuration:**
Create `_dev/sensitive_strings.txt` (gitignored) with patterns to check:
```
# One pattern per line, case-insensitive grep
# Lines starting with # are ignored
quintoandar
david\.erich
```

**What it checks:**
- Searches HEAD commit for patterns in `sensitive_strings.txt`
- Skips check on `_local` and other `_*` branches
- Fails on `main` or other public branches

### Git Pre-commit Hook

Both scripts run automatically via `.git/hooks/pre-commit` before commits.

**To run manually:**
```shell
.git/hooks/pre-commit
```

**To bypass (not recommended):**
```shell
git commit --no-verify
# or with jj:
jj git push --allow-empty-description
```

**Setup:**
- Hook: `.git/hooks/pre-commit` (local, not tracked)
- Scripts: `_dev/*.sh` (local, excluded via `.git/info/exclude`)
- Works with both git and jj (jj uses git under the hood)
