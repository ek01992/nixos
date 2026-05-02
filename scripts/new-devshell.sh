#!/usr/bin/env bash
set -euo pipefail

NAME="${1:-}"

usage() {
  echo "Usage: $0 <name>" >&2
  echo "  Creates modules/devshells/<name>.nix with a perSystem.devShells.<name> stub" >&2
  exit 1
}

[[ -z "$NAME" ]] && { echo "error: shell name is required" >&2; usage; }

DEVSHELLS_DIR="modules/devshells"
DEVSHELL_FILE="$DEVSHELLS_DIR/$NAME.nix"

[[ -e "$DEVSHELL_FILE" ]] && { echo "error: $DEVSHELL_FILE already exists" >&2; exit 1; }

mkdir -p "$DEVSHELLS_DIR"

cat > "$DEVSHELL_FILE" <<'EOF'
{ self, inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      devShells.@NAME@ = pkgs.mkShell {
        packages = with pkgs; [
          # TODO: Add development tools
        ];

        shellHook = ''
          echo "Entered @NAME@ devShell"
          # TODO: Add shell initialization
        '';
      };
    };
}
EOF
sed -i "s/@NAME@/$NAME/g" "$DEVSHELL_FILE"

git add "$DEVSHELL_FILE"

echo "Created: $DEVSHELL_FILE"
echo ""
echo "Files staged with git add."
echo ""
echo "Next steps:"
echo "  1. Edit $DEVSHELL_FILE — add packages and shellHook"
echo "  2. nixfmt-tree"
echo "  3. nix flake check"
echo "  4. Enter with: nix develop .#$NAME"
