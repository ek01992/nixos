---
name: nixos-scaffold
description: Scaffold new NixOS flake components — hosts, features, wrapped packages, devShells — from on-architecture templates
version: 1.0.0
source: project-local
---

# NixOS Scaffold

Generates boilerplate for new flake components using bash scripts that embed exact repo-pattern templates. Run all commands from the repo root.

## Trigger Phrases

- `/nixos-scaffold host <hostname> [bare-metal|wsl]`
- `/nixos-scaffold feature <name> [mode]`
- `/nixos-scaffold devshell <name>`
- `"Scaffold a new host"`
- `"Add a new feature module"`
- `"Create a devShell"`

---

## Commands

### New Host

```bash
./scripts/new-host.sh <hostname> [bare-metal|wsl]
```

Default type: `bare-metal`

Creates `modules/hosts/<hostname>/`:
- `default.nix` — `flake.nixosConfigurations.<hostname>` wiring
- `configuration.nix` — `flake.nixosModules.<hostname>Configuration` with imports, user, stateVersion
- `hardware.nix` — `flake.nixosModules.<hostname>Hardware` with filesystem stubs and TODO UUID markers

**bare-metal**: systemd-boot, networkmanager, Intel microcode, `/boot` vfat + `/` ext4 stubs  
**wsl**: `inputs.nixos-wsl.nixosModules.default` import, `wsl.enable`, WSL-specific filesystem mounts

**Required post-scaffold edits** (hardware.nix will fail `nix flake check` until filled in):
- Replace `TODO-ROOT-UUID`, `TODO-BOOT-UUID`, `TODO-SWAP-UUID` with real disk UUIDs
  - Get them: `lsblk -o NAME,UUID` or `nixos-generate-config --show-hardware-config`
- For bare-metal: add `availableKernelModules` matching the hardware

### New Feature Module

```bash
./scripts/new-feature.sh <name> [mode]
```

Default mode: `--both`

| Mode | Output | Use when |
|---|---|---|
| `--nixos-module-only` | `modules/features/<name>.nix` with `flake.nixosModules.<name>` | Pure NixOS config, no package |
| `--package-only` | `modules/features/<name>.nix` with `perSystem.packages.<name>` | Package derivation, no NixOS module |
| `--both` | Both sections in one file (like `niri.nix`) | NixOS module that uses a custom package |
| `--wrapped <wrapper>` | `modules/features/<name>/` dir with `.nix` + `.json` | wrapper-modules wrapper (niri, noctalia-shell, …) |

For `--wrapped`, the wrapper name is passed directly to `inputs.wrapper-modules.wrappers.<wrapper>.wrap`. Check available wrappers in the wrapper-modules input.

**Post-scaffold:** Edit the generated `# TODO` sections. For `--wrapped`, populate `<name>.json` — see `modules/features/noctalia/noctalia.json` for structure.

**To enable on a host:** add `self.nixosModules.<name>` to the imports list in the host's `configuration.nix`.

### New devShell

```bash
./scripts/new-devshell.sh <name>
```

Creates `modules/devshells/<name>.nix` with `perSystem.devShells.<name>` using `pkgs.mkShell`. The `modules/devshells/` directory is auto-discovered by import-tree — no registration needed.

**Enter the shell:** `nix develop .#<name>`

---

## Post-Scaffold Checklist (all commands)

1. Files are git-staged automatically — no manual `git add` needed
2. Edit all `# TODO` markers in the generated files
3. `nixfmt-tree` — normalize Nix formatting
4. `nix flake check` — verify the file evaluates
5. `nixos-rebuild build --flake .#<hostname>` — verify the full host builds (for host scaffolds or after adding a feature to a host)

---

## Module Naming Conventions

Scripts derive these names from the `<hostname>` or `<name>` argument:

| Artifact | Pattern | Example |
|---|---|---|
| nixosConfiguration | `flake.nixosConfigurations.<hostname>` | `.nixos-wsl` |
| NixOS module | `flake.nixosModules.<hostname>Configuration` | `.nixos-wslConfiguration` |
| Hardware module | `flake.nixosModules.<hostname>Hardware` | `.nixos-wslHardware` |
| Feature module | `flake.nixosModules.<name>` | `.niri` |
| Package | `perSystem.packages.<name>` | `.myNiri` |
| devShell | `perSystem.devShells.<name>` | `.default` |

Note: the host directory name under `modules/hosts/` may differ from the flake output name (e.g., dir `wsl` → output `nixos-wsl`). Scripts use `<hostname>` as both the dir name and output name for new hosts.
