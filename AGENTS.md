# AI Assistant Collaboration Guide

This document provides guidelines for AI assistants working with this NixOS configuration repository.

## Repository Structure

This configuration uses a modular flake architecture designed for maintainability and scalability:

- **`flake.nix`**: Entry point with `mkSystem` helper function for multi-host support
- **`hosts/`**: Host-specific configurations (hardware, networking, ZFS mounts)
- **`modules/`**: Reusable NixOS modules organized by category
- **`profiles/`**: Composed configurations that import and configure modules

## Reference Documentation

- **[NIXOS-PATTERNS.md](NIXOS-PATTERNS.md)**: Advanced patterns, performance tuning, package management, and development workflows
- **[CONTRIBUTING.md](CONTRIBUTING.md)**: Workflow standards and commit conventions
- **[README.md](README.md)**: Quick start guide and common tasks

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

### Module Hierarchy

This configuration uses a simplified two-level hierarchy with a **container-only pattern**:

**Level 1**: Category modules (`modules/category/default.nix`) - **Pure Organizational Containers**
```nix
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myCategory;
in {
  options.myCategory = {
    enable = mkEnableOption "category description";
  };

  imports = [
    ./feature1.nix  # Direct submodule import
    ./feature2.nix
  ];

  config = mkIf cfg.enable {
    # NO LOGIC HERE - category modules are pure containers
    # All configuration logic lives in submodules
  };
}
```

**Level 2**: Feature modules (`modules/category/feature.nix`)
```nix
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myCategory.feature;
in {
  options.myCategory.feature = {
    enable = mkEnableOption "feature description";
    # Feature-specific options
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
- No intermediate enable options - direct submodule control
- Submodules manage their own enable states
- **Category modules are pure organizational containers** - no logic, only imports
- **All configuration logic lives in submodules** - create dedicated submodules for each service/feature

## Module Template Pattern

While not mandatory, this template provides a helpful starting point for new modules:

```nix
# <Module Name> Module
# Verification: <command to verify it's working>
# Why: <one-line reason this module exists>
{ config, lib, pkgs, ... }:
let 
  cfg = config.myCategory.feature;
  inherit (lib) mkEnableOption mkOption mkIf types mkDefault;
in {
  options.myCategory.feature = {
    enable = mkEnableOption "<description>";
    # Add options with defaults wrapped in mkDefault in config section
  };
  
  config = mkIf cfg.enable {
    # Use lib.mkDefault for any values that should be overridable
    services.something.enable = lib.mkDefault true;
    services.something.settings = lib.mkDefault { ... };
  };
}
```

**Key patterns highlighted:**
- Verification command in header comment
- Explicit `inherit (lib)` for clarity
- `lib.mkDefault` for overridable configuration values
- Consistent `myCategory.feature` namespace

**Note**: This is a helpful reference pattern, not a rigid requirement. Adapt as needed for your specific use case.

## Adding Components

### Adding a New Module

1. **Create the module file**: `modules/category/name.nix`
2. **Define options and config**:
   ```nix
   { config, lib, pkgs, ... }:
   with lib;
   let cfg = config.myCategory.name;
   in {
     options.myCategory.name = {
       enable = mkEnableOption "feature description";
       # Additional options with types, defaults, descriptions
     };

     config = mkIf cfg.enable {
       # Actual NixOS configuration
     };
   }
   ```
3. **Import in category default.nix**: Add to `modules/category/default.nix` imports
4. **Enable in host**: Set `myCategory.name.enable = true;` (direct submodule control)

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

### Module Hierarchy Changes (2025-01-XX)
**Background**: The configuration was simplified from a 4-level to a 2-level hierarchy by removing redundant intermediate enable options.

**Before (4 levels)**:
```nix
myVirtualization = {
  enable = true;
  enableIncus = true;  # ← Intermediate option (REMOVED)
};
myVirtualization.incus.enable = true;  # ← Direct option (KEPT)
```

**After (2 levels)**:
```nix
myVirtualization.enable = true;        # ← Category enable
myVirtualization.incus.enable = true;  # ← Direct submodule enable
```

**Impact**: Host configurations must now use direct submodule enables instead of intermediate options. See CHANGELOG.md for complete migration examples.

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
- Enable categories first, then specific features: `myCategory.enable = true; myCategory.feature.enable = true;`
- Avoid intermediate enable options - use direct submodule control

### Testing and Validation
- Run `just check` to validate syntax
- Use `just build` to test configuration
- Format code with `just fmt`
- Test on VM before applying to physical host

## Helper Functions

This configuration provides helper functions in `lib/default.nix` to reduce boilerplate and enforce consistency.

### Available Helpers

#### Module Helpers (`lib.mkModule`, `lib.mkServiceModule`)
```nix
# Basic module creation
lib.mkModule {
  name = "myfeature";
  category = "myCategory";
  config = {
    # Your configuration here
  };
}

# Service module with systemd integration
lib.mkServiceModule {
  name = "myservice";
  category = "myServices";
  serviceName = "my-service";
  description = "My Custom Service";
  config = {
    ExecStart = "/path/to/script";
  };
}
```

#### Secret Helpers (`lib.mkSecret`, `lib.mkSecretPath`, `lib.mkSecrets`)
```nix
# Basic secret creation
lib.mkSecret {
  name = "mysecret";
  file = "../../secrets/mysecret.age";
  owner = "root";
  mode = "0400";
}

# Secret with automatic path resolution
lib.mkSecretPath {
  name = "mysecret";
  secretFile = "mysecret.age";  # Automatically resolves to ../../secrets/
}

# Multiple secrets from list
lib.mkSecrets [
  { name = "secret1"; file = "../../secrets/secret1.age"; }
  { name = "secret2"; file = "../../secrets/secret2.age"; }
]
```

#### Systemd Service Helpers (`lib.mkSystemdService`, `lib.mkSystemdServiceRestart`, `lib.mkSystemdTimer`)
```nix
# Basic oneshot service
lib.mkSystemdService {
  name = "myservice";
  description = "My Service";
  script = "/path/to/script";
}

# Service with restart behavior
lib.mkSystemdServiceRestart {
  name = "myservice";
  description = "My Service";
  script = "/path/to/script";
  restart = "on-failure";
}

# Timer service
lib.mkSystemdTimer {
  name = "mytimer";
  description = "My Timer";
  script = "/path/to/script";
  onCalendar = "daily";
}
```

#### Networking Helpers (`lib.mkBridge`, `lib.mkFirewallRule`, `lib.mkTailscale`)
```nix
# Bridge configuration
lib.mkBridge {
  name = "mybridge";
  interface = "eth0";
  macAddress = "02:00:00:00:00:01";
}

# Firewall rule
lib.mkFirewallRule {
  port = 8080;
  protocol = "tcp";
  interface = "tailscale0";
}

# Tailscale configuration
lib.mkTailscale {
  enable = true;
  authKeyFile = "/path/to/key";
}
```

### When to Use Helpers

**Use helpers when:**
- Creating new modules with standard patterns
- Managing secrets with agenix
- Setting up systemd services
- Configuring networking components

**Don't use helpers when:**
- Configuration is highly custom or unique
- You need fine-grained control over options
- The helper doesn't fit your specific use case

### Importing Helpers

Helpers are automatically available in all modules via the flake's lib output:

```nix
# In any module
{ config, lib, pkgs, ... }:
let
  # Helpers are available as lib.mkModule, lib.mkSecret, etc.
  myConfig = lib.mkModule { ... };
in {
  # Your module configuration
}
```

## Module Categories

- **`system/`**: Boot (systemd-boot), locale, auto-upgrade, firmware
- **`networking/`**: Hostname, firewall, bridges, Tailscale
- **`services/`**: SSH, ZFS (scrubbing/trimming), firmware updates
- **`virtualization/`**: KVM-GT (Intel GPU passthrough), Incus (containers/VMs)
- **`users/`**: User accounts, SSH keys, groups

## Examples

### Category Module Pattern (Container-Only)
```nix
# modules/services/default.nix (Category level - Pure Container)
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myServices;
in {
  options.myServices = {
    enable = mkEnableOption "services configuration";
  };

  imports = [
    ./firmware.nix  # Dedicated submodule for firmware
    ./zfs.nix
    ./ssh.nix
  ];

  config = mkIf cfg.enable {
    # NO LOGIC HERE - all logic moved to submodules
  };
}
```

### Feature Module Pattern
```nix
# modules/services/ssh.nix (Feature level)
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myServices.ssh;
in {
  options.myServices.ssh = {
    enable = mkEnableOption "SSH daemon";
    port = mkOption {
      type = types.int;
      default = 22;
      description = "SSH daemon port";
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings.Port = cfg.port;
    };
  };
}
```

### Host with Direct Submodule Control
```nix
# hosts/custom/default.nix
{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/server
  ];

  # Category-level configuration
  myNetworking = {
    hostName = "custom";
    enableFirewall = true;
    bridgeName = "custombr0";
    bridgeInterface = "eth0";
    bridgeMacAddress = "02:00:00:00:00:01";
  };

  # Direct submodule enables (no intermediate options)
  mySystem.enable = true;
  mySystem.boot.enable = true;
  mySystem.locale.enable = true;
  myServices.enable = true;
  myServices.zfs.enable = true;
  myServices.ssh.enable = true;
  myVirtualization.enable = true;
  myVirtualization.kvmgt.enable = true;
  myVirtualization.incus.enable = true;
  myUsers.enable = true;
}
```

## Migration from 4-Level to 2-Level Hierarchy

**Before (2025-01-XX)**:
```nix
myVirtualization = {
  enable = true;
  enableKvmgt = true;  # ← REMOVED
  enableIncus = true;  # ← REMOVED
};
```

**After (2025-01-XX)**:
```nix
myVirtualization.enable = true;        # ← Category enable
myVirtualization.kvmgt.enable = true;  # ← Direct submodule
myVirtualization.incus.enable = true;  # ← Direct submodule
```

This simplified structure eliminates redundancy while maintaining granular control over individual features.
