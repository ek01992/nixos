# Development Workflow (NixOS)

## Feature Implementation Workflow

0. **Research & Reuse**
   - Use the `nixos` MCP tool for package/option lookups before writing new Nix expressions.
   - Search nixpkgs source and GitHub for existing module patterns.
   - Check `wrapper-modules` and `flake-parts` docs for API details.

1. **Plan**
   - Identify which hosts are affected.
   - Decide: new feature module (`modules/features/`) or host-specific change?
   - No new file needs registering — `import-tree` auto-discovers.

2. **Implement**
   - Follow the flake-parts module header pattern from the nixos-patterns skill.
   - Edit the JSON directly for noctalia widget/bar changes; no .nix edit needed.

3. **Validate** (run all before committing)
   ```bash
   nix flake check
   nixos-rebuild build --flake .#nixos-wsl
   nixos-rebuild build --flake .#nixxy
   nixfmt-tree
   ```

4. **Commit** — use the short informal style (see git-workflow.md)
