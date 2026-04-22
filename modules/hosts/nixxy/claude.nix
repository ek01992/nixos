{ self, inputs, ... }: {

  flake.nixosModules.nixxyClaudeConfig = { config, pkgs, lib, ... }: {

    environment.systemPackages = [ pkgs.jq ];

    system.activationScripts.claudeMcpFix = lib.stringAfter [ "users" ] ''
      JQ="${pkgs.jq}/bin/jq"
      MCP_FILES=(
        "/home/erik/.ai/everything-claude-code/.mcp.json"
        "/home/erik/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/context7/.mcp.json"
        "/home/erik/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/playwright/.mcp.json"
      )
      for f in "''${MCP_FILES[@]}"; do
        if [[ -f "$f" ]] && "$JQ" -e '.. | objects | select(.command? == "npx")' "$f" >/dev/null 2>&1; then
          echo "Patching MCP config: $f"
          "$JQ" 'walk(if type == "object" and .command? == "npx" then .command = "bunx" | .args = [.args[] | select(. != "-y")] else . end)' \
            "$f" > "$f.tmp" \
            && chown --reference="$f" "$f.tmp" \
            && mv "$f.tmp" "$f"
        fi
      done
    '';
  };
}
