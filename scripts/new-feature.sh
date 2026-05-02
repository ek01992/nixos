#!/usr/bin/env bash
set -euo pipefail

NAME="${1:-}"
MODE="${2:---both}"
WRAPPER="${3:-}"

usage() {
  echo "Usage: $0 <name> [--nixos-module-only|--package-only|--both|--wrapped <wrapper>]" >&2
  echo "  --nixos-module-only  flake.nixosModules.<name> only" >&2
  echo "  --package-only       perSystem.packages.<name> with mkDerivation stub" >&2
  echo "  --both               NixOS module + package in one file (default)" >&2
  echo "  --wrapped <wrapper>  wrapper-modules wrapper + JSON stub (e.g. noctalia-shell, niri)" >&2
  exit 1
}

[[ -z "$NAME" ]] && { echo "error: feature name is required" >&2; usage; }
[[ "$MODE" == "--wrapped" && -z "$WRAPPER" ]] && { echo "error: --wrapped requires a wrapper name" >&2; usage; }

FEATURE_FILE="modules/features/$NAME.nix"
FEATURE_DIR="modules/features/$NAME"

case "$MODE" in
  --nixos-module-only)
    [[ -e "$FEATURE_FILE" ]] && { echo "error: $FEATURE_FILE already exists" >&2; exit 1; }
    cat > "$FEATURE_FILE" <<'EOF'
{ self, inputs, ... }:
{
  flake.nixosModules.@NAME@ =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      # TODO: Add module options and configuration
    };
}
EOF
    sed -i "s/@NAME@/$NAME/g" "$FEATURE_FILE"
    git add "$FEATURE_FILE"
    echo "Created: $FEATURE_FILE"
    ;;

  --package-only)
    [[ -e "$FEATURE_FILE" ]] && { echo "error: $FEATURE_FILE already exists" >&2; exit 1; }
    cat > "$FEATURE_FILE" <<'EOF'
{ self, inputs, ... }:
{
  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.@NAME@ = pkgs.stdenv.mkDerivation {
        pname = "@NAME@";
        version = "0.1.0";
        # TODO: Add src, buildPhase, installPhase
      };
    };
}
EOF
    sed -i "s/@NAME@/$NAME/g" "$FEATURE_FILE"
    git add "$FEATURE_FILE"
    echo "Created: $FEATURE_FILE"
    ;;

  --both)
    [[ -e "$FEATURE_FILE" ]] && { echo "error: $FEATURE_FILE already exists" >&2; exit 1; }
    cat > "$FEATURE_FILE" <<'EOF'
{ self, inputs, ... }:
{
  flake.nixosModules.@NAME@ =
    { pkgs, lib, ... }:
    {
      # TODO: Enable package and configure NixOS module
      # programs.@NAME@ = {
      #   enable = true;
      #   package = self.packages.${pkgs.stdenv.hostPlatform.system}.@NAME@;
      # };
    };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.@NAME@ = pkgs.stdenv.mkDerivation {
        pname = "@NAME@";
        version = "0.1.0";
        # TODO: Add src, buildPhase, installPhase
      };
    };
}
EOF
    sed -i "s/@NAME@/$NAME/g" "$FEATURE_FILE"
    git add "$FEATURE_FILE"
    echo "Created: $FEATURE_FILE"
    ;;

  --wrapped)
    [[ -d "$FEATURE_DIR" ]] && { echo "error: $FEATURE_DIR already exists" >&2; exit 1; }
    mkdir -p "$FEATURE_DIR"

    cat > "$FEATURE_DIR/$NAME.nix" <<'EOF'
{ self, inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.@NAME@ = inputs.wrapper-modules.wrappers.@WRAPPER@.wrap {
        inherit pkgs;
        settings = (builtins.fromJSON (builtins.readFile ./@NAME@.json)).settings;
      };
    };
}
EOF
    sed -i "s/@NAME@/$NAME/g; s/@WRAPPER@/$WRAPPER/g" "$FEATURE_DIR/$NAME.nix"

    cat > "$FEATURE_DIR/$NAME.json" <<EOF
{
  "settings": {
  }
}
EOF

    git add "$FEATURE_DIR/"
    echo "Created:"
    echo "  $FEATURE_DIR/$NAME.nix"
    echo "  $FEATURE_DIR/$NAME.json"
    ;;

  *)
    echo "error: unknown mode: $MODE" >&2
    usage
    ;;
esac

echo ""
echo "Files staged with git add."
echo ""
echo "Next steps:"
if [[ "$MODE" == "--wrapped" ]]; then
  echo "  1. Edit $FEATURE_DIR/$NAME.json — add wrapper settings"
  echo "     (see modules/features/noctalia/noctalia.json for structure)"
else
  echo "  1. Edit $FEATURE_FILE — implement the TODO sections"
fi
if [[ "$MODE" == "--nixos-module-only" || "$MODE" == "--both" ]]; then
  echo "  2. To enable on a host: add self.nixosModules.$NAME to imports"
  echo "     in modules/hosts/<hostname>/configuration.nix"
fi
echo "  3. nixfmt-tree"
echo "  4. nix flake check"
