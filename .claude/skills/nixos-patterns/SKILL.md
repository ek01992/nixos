---
name: nixos-patterns
description: NixOS flake configuration patterns extracted from this repository
version: 1.0.0
source: local-git-analysis
analyzed_commits: 47
---

# NixOS Flake Patterns

This repository is a NixOS flake configuration for two hosts (`nixos-wsl` and `nixxy`) using `flake-parts` + `import-tree` for auto-discovery.

## Repository Structure

```
flake.nix                          # Minimal entry — delegates to flake-parts + import-tree
modules/
├── parts.nix                      # Declares supported systems
├── features/                      # Reusable NixOS modules
│   ├── niri.nix                   # Wayland compositor + perSystem package
│   └── noctalia/
│       ├── noctalia.nix           # Status bar perSystem package
│       └── noctalia.json          # Bar/widget settings (edit directly)
└── hosts/
    ├── nixxy/                     # Bare metal host (Wayland, pipewire)
    │   ├── default.nix            # nixosConfigurations.<host> definition
    │   ├── configuration.nix      # nixosModules.<host>Configuration
    │   └── hardware.nix           # nixosModules.<host>Hardware
    └── wsl/                       # WSL2 host
        ├── default.nix
        ├── configuration.nix
        └── hardware.nix
```

## Module File Header Pattern

Every `.nix` file in `modules/` is a flake-parts module and receives these args:

```nix
{ self, inputs, ... }:
{
  # flake-level outputs:
  flake.nixosModules.<name> = { config, pkgs, lib, ... }: { ... };
  flake.nixosConfigurations.<host> = inputs.nixpkgs.lib.nixosSystem { ... };

  # per-architecture outputs:
  perSystem = { pkgs, lib, self', ... }: {
    packages.<name> = ...;
  };
}
```

## Adding a New Host

1. Create `modules/hosts/<hostname>/default.nix` — defines `flake.nixosConfigurations.<hostname>`
2. Create `modules/hosts/<hostname>/configuration.nix` — defines `flake.nixosModules.<hostname>Configuration`, imports hardware + features
3. Create `modules/hosts/<hostname>/hardware.nix` — defines `flake.nixosModules.<hostname>Hardware`

No registration needed — `import-tree` auto-discovers all `.nix` files.

## Adding a New Feature Module

1. Create `modules/features/<feature>.nix`
2. Expose as `flake.nixosModules.<feature>`
3. Import it in the target host's `configuration.nix` via `self.nixosModules.<feature>`

## Package Wrapping Pattern (wrapper-modules)

Use `inputs.wrapper-modules.wrappers.<tool>.wrap` to build declaratively configured packages:

```nix
perSystem = { pkgs, lib, self', ... }: {
  packages.myTool = inputs.wrapper-modules.wrappers.<tool>.wrap {
    inherit pkgs;
    settings = { ... };
  };
};
```

Reference the package in NixOS modules via `self.packages.${pkgs.stdenv.hostPlatform.system}.myTool` (flake level) or `self'.packages.myTool` (perSystem level).

## JSON Settings for Wrapped Tools

For noctalia (and similar tools), settings live in a `.json` file, not inline Nix:

```nix
settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
```

Edit the JSON directly — no Nix changes needed for widget/bar tweaks.

## Host Configuration Template

```nix
{ self, inputs, ... }:
{
  flake.nixosModules.<host>Configuration =
    { config, pkgs, lib, ... }:
    {
      imports = [
        self.nixosModules.<host>Hardware
        self.nixosModules.<feature>   # add feature modules here
      ];

      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      environment.systemPackages = with pkgs; [
        git wget curl bat fastfetch nixfmt nixfmt-tree
        # Add System Packages
      ];

      programs = { };
      services = { openssh.enable = true; };
      nixpkgs.config.allowUnfree = true;
      time.timeZone = "America/Chicago";

      users.users.erik = {
        isNormalUser = true;
        description = "Erik Kowald";
        extraGroups = [ "wheel" ];
        packages = with pkgs; [ ];
      };

      system.stateVersion = "26.05";
    };
}
```

## Commit Conventions

This repo uses short, informal commit messages (not conventional commits):
- `fix` — iterative fixes (most common — expect many of these)
- `feat: <description>` — new capability added
- `rm <thing>` — removal
- `lock` — flake.lock update only
- `treefmt` — formatting pass only

When committing, match this style: keep it short and direct.

## Validation Workflow

Before committing any change:

```bash
nix flake check                          # Structural validity
nixos-rebuild build --flake .#nixos-wsl  # WSL host builds
nixos-rebuild build --flake .#nixxy      # bare metal host builds
nixfmt-tree                              # Format all .nix files
```

## Most Frequently Changed Files

| File | Change frequency |
|------|-----------------|
| `modules/hosts/nixxy/configuration.nix` | Highest (feature/package additions) |
| `modules/hosts/wsl/configuration.nix` | High (mirrors nixxy where applicable) |
| `modules/hosts/wsl/hardware.nix` | High (WSL hardware tuning) |
| `flake.lock` | Regular (input updates) |
| `modules/features/niri.nix` | Moderate (keybinds, layout) |
| `modules/features/noctalia/noctalia.json` | Moderate (bar widget config) |

## Key Inputs

| Input | Purpose |
|-------|---------|
| `nixpkgs` | Package set (nixos-unstable) |
| `flake-parts` | Modular flake composition |
| `import-tree` | Auto-imports all `.nix` under `modules/` |
| `nixos-wsl` | WSL2 NixOS support |
| `wrapper-modules` | Declarative niri/noctalia wrapping |
