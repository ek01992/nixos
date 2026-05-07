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

Then remind the user to add it to their host file under `imports`:
- `nixos-wsl`: `modules/hosts/nixos-wsl.nix`
- `nixxy`: `modules/hosts/nixxy.nix`

Finally, run `nfc` (nix flake check) to verify the module is valid.
