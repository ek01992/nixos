#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TODAY=$(date +%Y-%m-%d)

usage() {
  echo "Usage: $0 <source-nix-path>" >&2
  echo "  source-nix-path: path to the .nix source file (relative to repo root)" >&2
  echo "  Creates a wiki stub at the corresponding wiki/ path." >&2
  echo "" >&2
  echo "  Examples:" >&2
  echo "    $0 modules/features/foo.nix" >&2
  echo "    $0 modules/common.nix" >&2
  exit 1
}

[[ $# -ne 1 ]] && usage

SOURCE="$1"

# Normalize to relative path from repo root
if [[ "$SOURCE" = /* ]]; then
  SOURCE="${SOURCE#"$REPO_ROOT/"}"
fi

# Validate source exists
[[ ! -f "$REPO_ROOT/$SOURCE" ]] && { echo "error: $REPO_ROOT/$SOURCE does not exist" >&2; exit 1; }

# Derive wiki path from source path:
#   modules/features/foo.nix  ->  wiki/features/foo.md
#   modules/common.nix        ->  wiki/modules/common.md
WIKI_RELATIVE="${SOURCE#modules/}"
WIKI_RELATIVE="${WIKI_RELATIVE%.nix}.md"

# Top-level modules/ files go under wiki/modules/
if [[ "$WIKI_RELATIVE" != */* ]]; then
  WIKI_RELATIVE="modules/$WIKI_RELATIVE"
fi

WIKI_PATH="$REPO_ROOT/wiki/$WIKI_RELATIVE"

# Validate wiki target does not already exist
[[ -e "$WIKI_PATH" ]] && { echo "error: $WIKI_PATH already exists" >&2; exit 1; }

# Derive type from source path
if [[ "$SOURCE" == modules/features/* ]]; then
  TYPE="feature"
elif [[ "$SOURCE" == modules/hosts/* ]]; then
  TYPE="host"
else
  TYPE="concept"
fi

# Derive title: basename without extension, hyphens/underscores -> spaces, title-case
BASENAME=$(basename "$SOURCE" .nix)
TITLE=$(echo "$BASENAME" | sed 's/[-_]/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')

# Create parent directory if needed
mkdir -p "$(dirname "$WIKI_PATH")"

# Write stub — use <<'EOF' to prevent bash from expanding Nix ${} syntax
cat > "$WIKI_PATH" <<'EOF'
---
title: @TITLE@
type: @TYPE@
updated: @TODAY@
sources:
  - @SOURCE@
---

# @TITLE@

TODO: describe what this module exports, what it configures, and what it depends on.
EOF

# Substitute placeholders
sed -i \
  -e "s|@TITLE@|$TITLE|g" \
  -e "s|@TYPE@|$TYPE|g" \
  -e "s|@TODAY@|$TODAY|g" \
  -e "s|@SOURCE@|$SOURCE|g" \
  "$WIKI_PATH"

git -C "$REPO_ROOT" add "$WIKI_PATH"

echo "Created:"
echo "  $WIKI_PATH"
echo ""
echo "Files staged with git add."
echo ""
echo "Next steps:"
echo "  1. Edit $WIKI_PATH — fill in the TODO section"
echo "  2. /wiki-update $SOURCE  — populate from source and update index + log"
echo "  3. /wiki-lint            — verify no coverage warnings remain"
