# Contributing Guidelines

This is a personal NixOS configuration repository. These guidelines ensure consistency and maintainability.

## Setup

1. **Install Nix**: Follow the [official installation guide](https://nixos.org/download.html)
2. **Enable Flakes**: Add to your Nix configuration:
   ```nix
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   ```
3. **Install Just**: `nix-env -iA nixpkgs.just`

## Workflow

### Branch Strategy
- `main`: Production-ready configurations
- `feature/*`: New features or modules
- `fix/*`: Bug fixes
- `hotfix/*`: Urgent production fixes

### Making Changes

1. **Create Branch**: `just branch feature/my-feature`
2. **Make Changes**: Follow existing patterns
3. **Test**: `just check && just build`
4. **Format**: `just fmt`
5. **Commit**: `just commit "feat(scope): description"`
6. **Push**: `just push`

## Commit Standards

Follow [Conventional Commits](https://www.conventionalcommits.org/):

**Format**: `type(scope): description`

**Types**: feat, fix, docs, style, refactor, perf, test, chore, build, ci

**Rules**:
- Imperative mood ("add" not "added")
- No period at end
- Under 50 characters
- Scope from path (`modules/networking` → `networking`)

**Examples**:
- `feat(incus): add web UI configuration`
- `fix(zfs): correct scrub schedule`
- `docs(readme): update quick start commands`

## Adding Components

### New Module
1. Create `modules/category/name.nix`
2. Define `myCategory.feature` namespace
3. Use `mkEnableOption` and `mkOption` patterns
4. Import in `modules/category/default.nix`

### New Host
1. Create `hosts/hostname/default.nix`
2. Add `inputs` parameter for nixos-hardware access
3. Configure host-specific settings
4. Add to `flake.nix`: `hostname = mkSystem "hostname" "x86_64-linux"`

## Code Standards

- **Formatting**: Use `nix fmt` for all .nix files
- **Structure**: Follow existing module patterns (options, config, imports)
- **Documentation**: Document non-obvious configurations
- **Testing**: Run `just check` before committing

## Validation

Before committing:
```bash
just check    # Validate syntax and structure
just build    # Ensure configuration builds
just fmt      # Format code
```

## Common Patterns

### Module Structure
```nix
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myCategory.feature;
in {
  options.myCategory.feature = {
    enable = mkEnableOption "feature description";
    # ... other options
  };

  config = mkIf cfg.enable {
    # ... configuration
  };
}
```

### Host Configuration
```nix
{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/networking
    ../../modules/services
    ../../modules/virtualization
    ../../modules/users
    inputs.nixos-hardware.nixosModules.device-name
  ];

  # Host-specific configuration
  mySystem.enable = true;
  myNetworking.enable = true;
  # ... other modules
}
```
