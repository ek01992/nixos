---
name: new-feature
description: Scaffold a new NixOS feature module for this flake repo, following the import-tree pattern
---

When the user invokes /new-feature [name], create the file
`modules/features/<name>.nix` with this boilerplate:

```nix
{ lib, pkgs, config, ... }:
{
  flake.nixosModules.<name> = { ... }: {
    # system config here
    environment.systemPackages = [ ];

    home-manager.users.erik = { ... }: {
      # home-manager config here
    };
  };
}
```

Then remind the user to add `self.nixosModules.<name>` to the `imports` list in:
- WSL host: `modules/hosts/wsl/configuration.nix`
- nixxy host: `modules/hosts/nixxy/configuration.nix`

Finally, run `nfc` (nix flake check) to verify the module is valid.

Then invoke the `nix-reviewer` subagent on the new file to check for convention issues.
