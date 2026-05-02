{ self, inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          inputs.claude-code-nix.packages.${system}.default
          treefmt
          nixfmt-tree
          nixfmt
          neovim
          git
          gh
          nil
          deadnix
          statix
          ripgrep
          fd
          jq
        ];

        shellHook = ''
          export EDITOR=nvim
          export PS1="(nixos-dev) $PS1"

          if [[ -z "''${ANTHROPIC_API_KEY:-}" ]]; then
            echo "warning: ANTHROPIC_API_KEY is not set — claude will not work"
          fi

          echo "nixos dev"
          echo "  nix flake check"
          echo "  nixos-rebuild build --flake .#nixos-wsl"
          echo "  nixos-rebuild build --flake .#nixxy"
          echo "  nixfmt-tree"
        '';
      };
    };
}
