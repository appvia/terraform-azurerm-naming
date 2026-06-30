#!/usr/bin/env bash
set -euo pipefail

# Pre-commit hook that replaces __REPO_NAME__ placeholders in README.md
# with the actual repository name. Modifies the file in place — if changes
# are made, the hook exits 1 so the user can review, re-stage, and commit.

REPO_ROOT="$(git rev-parse --show-toplevel)"
README="$REPO_ROOT/README.md"
TEMPLATE_REPO_NAME="terraform-azurerm-module-template"

REPO_NAME="$(basename "$REPO_ROOT")"

# Skip if we're in the template repo itself
if [ "$REPO_NAME" = "$TEMPLATE_REPO_NAME" ]; then
  exit 0
fi

# Nothing to do if placeholder is not present
if ! grep -q '__REPO_NAME__' "$README" 2>/dev/null; then
  exit 0
fi

# Replace __REPO_NAME__ with the actual repo name
sed "s/__REPO_NAME__/${REPO_NAME}/g" "$README" > "$README.tmp" && mv "$README.tmp" "$README"

echo "init-from-template: Replaced __REPO_NAME__ with '$REPO_NAME' in README.md"
echo "Please review the changes, re-stage (git add README.md), and commit again."
exit 1
