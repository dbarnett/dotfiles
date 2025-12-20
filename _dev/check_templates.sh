#!/usr/bin/env sh
# Check that all chezmoi templates can render without hard dependencies on data values
#
# This script tests each template by attempting to render it with minimal data.
# Templates should use hasKey checks or default filters for all data access.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

ERRORS=0
TEMPLATES=$(find . -name "*.tmpl" -type f | grep -v "^\./\.git/" | grep -v "^\./_dev/" | sort)

if [ -z "$TEMPLATES" ]; then
  echo "No templates found"
  exit 0
fi

echo "Checking templates for hard data dependencies..."
echo ""

for template in $TEMPLATES; do
  # Skip create_ files - they're only created once, not continuously managed
  if echo "$template" | grep -q "^\./create_"; then
    continue
  fi

  # Try to render template with empty data
  # Use --init to simulate a fresh chezmoi state with no data
  if ! chezmoi execute-template --init < "$template" > /dev/null 2>&1; then
    echo "❌ $template: FAILED - template has hard dependency on data values"
    ERRORS=$((ERRORS + 1))
    # Show the actual error
    echo "   Error:"
    chezmoi execute-template --init < "$template" 2>&1 | sed 's/^/   /' | head -3 || true
    echo ""
  else
    echo "✅ $template: OK"
  fi
done

echo ""
if [ $ERRORS -eq 0 ]; then
  echo "All templates are safe (no hard data dependencies)"
  exit 0
else
  echo "Found $ERRORS template(s) with hard data dependencies"
  echo ""
  echo "Fix by using safe patterns:"
  echo "  - index with or: {{ or (index . \"key\") \"default\" }}"
  echo "  - hasKey checks: {{ if hasKey . \"key\" }}{{ .key }}{{ end }}"
  echo "  - output commands: {{ output \"git\" \"config\" \"user.email\" }}"
  echo ""
  echo "Note: {{ .key | default \"value\" }} is NOT safe - it accesses .key first"
  exit 1
fi
