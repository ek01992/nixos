#!/usr/bin/env bash
set -euo pipefail
input=$(cat)
file_path=$(echo "$input" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('file_path',''), end='')" 2>/dev/null || true)
[[ "$file_path" == */modules/*.nix ]] || exit 0
echo "wiki-remind: modules/ file changed — run /wiki-update $(basename "$file_path") if this affects public behavior"
