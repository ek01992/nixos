---
title: Shell (Fish + Starship)
type: feature
updated: 2026-05-02
sources:
  - modules/features/shell.nix
---

# Shell (Fish + Starship)

Sets fish as the default shell for user `erik` and configures it with aliases and a starship prompt. Requires [[features/home]] (the home-manager bridge).

## Exports

- `flake.nixosModules.shell` — fish shell + starship for user `erik`

Used by: [[hosts/nixxy]], [[hosts/nixos-wsl]] (imported as `self.nixosModules.shell`)

## What It Configures

```nix
programs.fish.enable = true;          # enables fish system-wide (adds to /etc/shells)
users.users.erik.shell = pkgs.fish;   # sets fish as erik's login shell

home-manager.users.erik = {
  programs.fish = {
    enable = true;
    shellAliases = {
      nrb = "nixos-rebuild build --flake $HOME/nixos";
      nrs = "sudo nixos-rebuild switch --flake $HOME/nixos";
      nfc = "nix flake check";
      nfu = "nix flake update";
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };
};
```

## Alias Duplication Note

The same four aliases (`nrb`, `nrs`, `nfc`, `nfu`) also exist in [[modules/common]] as bash aliases. This is intentional — `common.nix` handles bash for all NixOS users, while `shell.nix` handles fish for user `erik` specifically. Both hosts import both modules, so the aliases are available in either shell.

## Dependencies

Requires [[features/home]] — uses `home-manager.users.erik.*` options that the home bridge sets up.

## Cross-references

- Depends on: [[features/home]]
- Related (bash aliases): [[modules/common]]
- Active on: [[hosts/nixxy]], [[hosts/nixos-wsl]]
