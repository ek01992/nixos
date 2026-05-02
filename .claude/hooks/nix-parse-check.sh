#!/usr/bin/env bash
# PreToolUse hook: syntax-check .nix file content before Write/Edit lands
set -euo pipefail

input=$(cat)

# Extract file_path
file_path=$(echo "$input" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('file_path',''), end='')" 2>/dev/null || true)

# Only check .nix files
[[ "$file_path" == *.nix ]] || exit 0

# For Write: validate the new content before it's written
content=$(echo "$input" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('content',''), end='')" 2>/dev/null || true)

if [[ -n "$content" ]]; then
    tmp=$(mktemp /tmp/nix-parse-check-XXXXXX.nix)
    trap 'rm -f "$tmp"' EXIT
    printf '%s' "$content" > "$tmp"
    if ! nix-instantiate --parse "$tmp" >/dev/null 2>&1; then
        echo "nix-parse-check: syntax error in ${file_path}" >&2
        nix-instantiate --parse "$tmp" 2>&1 | head -20 >&2 || true
        exit 1
    fi
elif [[ -f "$file_path" ]]; then
    # For Edit: check the existing file parses before allowing modification
    if ! nix-instantiate --parse "$file_path" >/dev/null 2>&1; then
        echo "nix-parse-check: ${file_path} has existing syntax errors — fix before editing" >&2
        exit 1
    fi
fi

exit 0
