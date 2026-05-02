#!/usr/bin/env bash
# PostToolUse hook: run nixfmt-tree after any Write/Edit that touches a .nix file.
# Claude Code sets CLAUDE_TOOL_INPUT to the tool's JSON input parameters.
set -u

if echo "${CLAUDE_TOOL_INPUT:-}" | grep -q '\.nix"'; then
  nixfmt-tree 2>/dev/null || true
fi
