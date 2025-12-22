#!/usr/bin/env sh
# Check that no sensitive content is being committed
#
# Reads patterns from _dev/sensitive_strings.txt (gitignored)
# Each line should be a grep pattern (case-insensitive search)

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

PATTERNS_FILE="_dev/sensitive_strings.txt"

if [ ! -f "$PATTERNS_FILE" ]; then
  echo "✓ No sensitive strings config found ($PATTERNS_FILE)"
  exit 0
fi

# Get current branch/bookmark
SKIP_CHECK=0

if command -v jj >/dev/null 2>&1; then
  # Using jj: Check if there's a _* bookmark between main+ and @
  # This handles cases where @ is an in-progress change on top of a bookmark
  BOOKMARKS=$(jj log -r 'main+::@' --no-graph -T 'bookmarks ++ " "' 2>/dev/null || echo "")
  for bookmark in $BOOKMARKS; do
    case "$bookmark" in
      _*)
        echo "✓ Skipping sensitive content check - found private bookmark: $bookmark"
        SKIP_CHECK=1
        break
        ;;
    esac
  done
else
  # Not using jj: Check if git is explicitly on a _* branch
  CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
  case "$CURRENT_BRANCH" in
    _*)
      echo "✓ Skipping sensitive content check on private branch: $CURRENT_BRANCH"
      SKIP_CHECK=1
      ;;
  esac
fi

if [ $SKIP_CHECK -eq 1 ]; then
  exit 0
fi

CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")

echo "Checking for sensitive content on branch: $CURRENT_BRANCH"

ERRORS=0
PATTERNS=$(grep -v '^#' "$PATTERNS_FILE" | grep -v '^[[:space:]]*$' || true)

if [ -z "$PATTERNS" ]; then
  echo "✓ No patterns configured"
  exit 0
fi

ERROR_OUTPUT=""
for pattern in $PATTERNS; do
  # Check both HEAD (committed) and working directory (uncommitted changes)
  HEAD_MATCHES=$(git grep -i "$pattern" HEAD 2>/dev/null | grep -v "^HEAD:_dev/" || true)
  WD_MATCHES=$(git grep -i "$pattern" 2>/dev/null | grep -v "^_dev/" || true)

  if [ -n "$HEAD_MATCHES" ] || [ -n "$WD_MATCHES" ]; then
    ERROR_OUTPUT="$ERROR_OUTPUT
❌ Found '$pattern':"

    if [ -n "$HEAD_MATCHES" ]; then
      FORMATTED_HEAD=$(echo "$HEAD_MATCHES" | sed 's/^HEAD://; s/^/   [committed] /')
      ERROR_OUTPUT="$ERROR_OUTPUT
$FORMATTED_HEAD"
    fi

    if [ -n "$WD_MATCHES" ]; then
      FORMATTED_WD=$(echo "$WD_MATCHES" | sed 's/^/   [uncommitted] /')
      ERROR_OUTPUT="$ERROR_OUTPUT
$FORMATTED_WD"
    fi

    ERROR_OUTPUT="$ERROR_OUTPUT
"
    ERRORS=$((ERRORS + 1))
  fi
done

if [ $ERRORS -eq 0 ]; then
  echo "✓ No sensitive content found"
  exit 0
else
  echo "$ERROR_OUTPUT
⚠️  Found sensitive content matching $ERRORS pattern(s)

This content should not be committed to public branches.
Either:
  1. Remove/template the sensitive content
  2. Use machine_profile conditionals to make it work-only
  3. Move to .profile.local or other local files
  4. Commit to _local branch instead: jj bookmark set _local

To bypass this check: git commit --no-verify"
  exit 1
fi
