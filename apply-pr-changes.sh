#!/bin/bash
# Apply PR changes for configuration cleanup and profile removal
# Run from repository root: bash /path/to/apply-pr-changes.sh

set -e

REPO_ROOT="$(pwd)"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

echo "=== Applying PR: Configuration Cleanup and Profile Removal ==="
echo

# Safety check
if [[ ! -f "flake.nix" ]]; then
    echo "Error: Must run from repository root (flake.nix not found)"
    exit 1
fi

echo "Step 1: Creating .gitignore..."
cp "${SCRIPT_DIR}/.gitignore" "${REPO_ROOT}/.gitignore"
echo "✓ .gitignore created"
echo

echo "Step 2: Updating hosts/xps/default.nix..."
cp "${SCRIPT_DIR}/hosts-xps-default.nix" "${REPO_ROOT}/hosts/xps/default.nix"
echo "✓ hosts/xps/default.nix updated"
echo

echo "Step 3: Updating justfile..."
cp "${SCRIPT_DIR}/justfile" "${REPO_ROOT}/justfile"
echo "✓ justfile updated"
echo

echo "Step 4: Updating modules/virtualization/default.nix..."
cp "${SCRIPT_DIR}/modules-virtualization-default.nix" "${REPO_ROOT}/modules/virtualization/default.nix"
echo "✓ modules/virtualization/default.nix updated"
echo

echo "Step 5: Updating CHANGELOG.md..."
cp "${SCRIPT_DIR}/CHANGELOG.md" "${REPO_ROOT}/CHANGELOG.md"
echo "✓ CHANGELOG.md updated"
echo

echo "Step 6: Updating AGENTS.md..."
cp "${SCRIPT_DIR}/AGENTS.md" "${REPO_ROOT}/AGENTS.md"
echo "✓ AGENTS.md updated"
echo

echo "Step 7: Updating README.md..."
cp "${SCRIPT_DIR}/README.md" "${REPO_ROOT}/README.md"
echo "✓ README.md updated"
echo

echo "Step 8: Updating CONTRIBUTING.md..."
cp "${SCRIPT_DIR}/CONTRIBUTING.md" "${REPO_ROOT}/CONTRIBUTING.md"
echo "✓ CONTRIBUTING.md updated"
echo

echo "Step 9: Removing profiles directory..."
if [[ -d "${REPO_ROOT}/profiles" ]]; then
    rm -rf "${REPO_ROOT}/profiles"
    echo "✓ profiles/ directory removed"
else
    echo "⚠ profiles/ directory not found (already removed?)"
fi
echo

echo "=== All changes applied successfully ==="
echo
echo "Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Validate: nix flake check"
echo "  3. Test build: just build"
echo "  4. Format: just fmt"
echo "  5. Commit changes using conventional commits format"
echo
echo "Example commits:"
echo "  git commit -m 'fix(networking): document firewall disabled for development'"
echo "  git commit -m 'fix(justfile): remove imperative install command'"
echo "  git commit -m 'refactor(profiles): remove server profile entirely'"
echo
