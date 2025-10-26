# AI Assistant Collaboration Guide

This document provides guidelines for AI assistants working with this NixOS configuration repository.

## Repository Structure

This configuration uses a modular flake architecture designed for maintainability and scalability:

- **`flake.nix`**: Entry point with `mkSystem` helper function for multi-host support
- **`hosts/`**: Host-specific configurations (hardware, networking, ZFS mounts)
- **`modules/`**: Reusable NixOS modules organized by category
- **`profiles/`**: Composed configurations that import and configure modules

## Key Patterns

### mkSystem Helper Function

The flake uses a `mkSystem` helper to ensure consistent host configuration:

```nix
mkSystem = hostname: system:
  nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [ ./hosts/${hostname}/default.nix ];
  };
```

**Why this pattern exists**: 
- Ensures `system` parameter is always passed to `nixosSystem`
- Provides `inputs` via `specialArgs` for nixos-hardware access
- Makes adding new hosts trivial and consistent

### Module Structure

All modules follow this pattern:

```nix
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myCategory.feature;
in {
  options.myCategory.feature = {
    enable = mkEnableOption "feature description";
    # Additional options with types, defaults, descriptions
  };
  
  config = mkIf cfg.enable {
    # Actual NixOS configuration
  };
}
```

**Key points**:
- Use `myCategory.feature` namespace to avoid conflicts
- Always define `enable` option with `mkEnableOption`
- Use `mkIf cfg.enable` to make features optional
- Import submodules in `default.nix` files

## Adding Components

### Adding a New Module

1. **Create the module file**: `modules/category/name.nix`
2. **Define options and config**:
   ```nix
   options.myCategory.name = {
     enable = mkEnableOption "description";
     # ... other options
   };
   
   config = mkIf cfg.enable {
     # ... configuration
   };
   ```
3. **Import in profile**: Add to `profiles/server/default.nix` imports
4. **Enable in host**: Set `myCategory.name.enable = true;`

### Adding a New Host

1. **Create host directory**: `hosts/hostname/`
2. **Create `default.nix`**:
   ```nix
   { config, lib, pkgs, inputs, ... }:
   {
     imports = [
       ./hardware-configuration.nix
       ../../profiles/server
       inputs.nixos-hardware.nixosModules.device-name
     ];
     
     # Host-specific configuration
     myNetworking.hostName = "hostname";
     # ... other host-specific settings
   }
   ```
3. **Add to flake.nix**:
   ```nix
   nixosConfigurations = {
     hostname = mkSystem "hostname" "x86_64-linux";
   };
   ```

### Adding a New Profile

1. **Create profile directory**: `profiles/profilename/`
2. **Create `default.nix`**:
   ```nix
   { config, lib, pkgs, ... }:
   {
     options.profiles.profilename = {
       enable = mkEnableOption "profile description";
     };
     
     config = mkIf cfg.enable {
       # Import and configure modules
       mySystem.enable = true;
       myNetworking.enable = true;
       # ... other module configurations
     };
   }
   ```

## Common Pitfalls

### Missing System Parameter
**Problem**: `nixosSystem` requires explicit `system` parameter
**Solution**: Always use `mkSystem` helper or pass `system = "x86_64-linux"`

### Not Passing Inputs
**Problem**: nixos-hardware modules not accessible in host config
**Solution**: Pass `inputs` via `specialArgs` and import in host config

### Wrong Import Location
**Problem**: Hardware-specific imports in flake.nix
**Solution**: Import nixos-hardware modules in host configuration, not flake.nix

### Module Namespace Conflicts
**Problem**: Module options conflict with NixOS built-ins
**Solution**: Use `myCategory.feature` namespace consistently

## Best Practices

### Code Organization
- Keep modules focused on single responsibilities
- Use descriptive option names and descriptions
- Import submodules in `default.nix` files
- Group related functionality in same category

### Configuration Patterns
- Use `mkEnableOption` for boolean toggles
- Provide sensible defaults
- Use `mkIf` for conditional configuration
- Document non-obvious configurations

### Testing and Validation
- Run `just check` to validate syntax
- Use `just build` to test configuration
- Format code with `just fmt`
- Test on VM before applying to physical host

## Module Categories

- **`system/`**: Boot, locale, auto-upgrade, firmware
- **`networking/`**: Hostname, firewall, bridges, Tailscale
- **`services/`**: SSH, ZFS, firmware updates
- **`virtualization/`**: Incus, KVM-GT, container management
- **`users/`**: User accounts, SSH keys, groups

## Examples

### Simple Service Module
```nix
# modules/services/example.nix
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myServices.example;
in {
  options.myServices.example = {
    enable = mkEnableOption "example service";
    port = mkOption {
      type = types.int;
      default = 8080;
      description = "Service port";
    };
  };
  
  config = mkIf cfg.enable {
    systemd.services.example = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.example}/bin/example --port ${toString cfg.port}";
      };
    };
  };
}
```

### Host with Custom Networking
```nix
# hosts/custom/default.nix
{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/server
  ];
  
  myNetworking = {
    hostName = "custom";
    enableFirewall = true;
    bridgeName = "custombr0";
    bridgeInterface = "eth0";
    bridgeMacAddress = "02:00:00:00:00:01";
  };
}
```

This structure ensures maintainable, scalable NixOS configurations while preventing common errors through consistent patterns.
