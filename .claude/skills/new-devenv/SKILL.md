---
name: new-devenv
description: Scaffold a new development shell environment for this flake repo, following the perSystem/devShells pattern
---

When the user invokes /new-devenv [name], create the file
`modules/devshells/<name>.nix` with this boilerplate:

```nix
{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      devShells.<name> = pkgs.mkShell {
        packages = with pkgs; [
          # add project-specific tools here
        ];

        shellHook = ''
          echo "<name> dev shell"
        '';
      };
    };
}
```

Then remind the user to:
- Replace the `packages` list with the tools needed for this environment
  (use `mcp__nixos__nix` to search for package names if unsure)
- Customize the `shellHook` to print available commands or set environment variables
- Enter the shell with: `nix develop .#<name>`

Finally, run `nfc` (nix flake check) to verify the devShell definition is valid.
