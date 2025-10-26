# CHANGELOG

All notable changes to this NixOS configuration will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2025-01-XX] - Module Hierarchy Simplification

### BREAKING CHANGES

This release simplifies the module hierarchy by removing redundant intermediate enable options. The configuration now uses a cleaner two-level hierarchy where you enable a category and then directly enable specific features.

#### Affected Modules

**Virtualization Module** (`modules/virtualization/`)
- **Removed**: `myVirtualization.enableKvmgt`, `myVirtualization.enableIncus`
- **Impact**: Must now use `myVirtualization.kvmgt.enable`, `myVirtualization.incus.enable`

**System Module** (`modules/system/`)
- **Removed**: `mySystem.enableBoot`, `mySystem.enableLocale`
- **Impact**: Must now use `mySystem.boot.enable`, `mySystem.locale.enable`

**Services Module** (`modules/services/`)
- **Removed**: `myServices.enableZfs`, `myServices.enableSsh`
- **Impact**: Must now use `myServices.zfs.enable`, `myServices.ssh.enable`

**Server Profile** (`profiles/server/`)
- **Removed**: `enableSystem`, `enableNetworking`, `enableServices`, `enableVirtualization`, `enableUsers`, `enableSystemPackages`
- **Impact**: Profile now unconditionally enables all modules when `profiles.server.enable = true`

#### Migration Examples

**Before (4-level hierarchy)**:
```nix
# Virtualization
myVirtualization = {
  enable = true;
  enableKvmgt = true;  # ← REMOVED
  enableIncus = true;  # ← REMOVED
};
myVirtualization.incus.enable = true;  # ← Still works

# System
mySystem = {
  enable = true;
  enableBoot = true;   # ← REMOVED
  enableLocale = true; # ← REMOVED
  # ... other options
};
mySystem.boot.enable = true;  # ← Still works

# Services
myServices = {
  enable = true;
  enableZfs = true;    # ← REMOVED
  enableSsh = true;    # ← REMOVED
  # ... other options
};
myServices.zfs.enable = true; # ← Still works
```

**After (2-level hierarchy)**:
```nix
# Virtualization
myVirtualization.enable = true;        # Category enable
myVirtualization.kvmgt.enable = true;  # Direct submodule enable
myVirtualization.incus.enable = true;  # Direct submodule enable

# System
mySystem.enable = true;        # Category enable
mySystem.boot.enable = true;   # Direct submodule enable
mySystem.locale.enable = true; # Direct submodule enable
# ... other options unchanged

# Services
myServices.enable = true;      # Category enable
myServices.zfs.enable = true;  # Direct submodule enable
myServices.ssh.enable = true;  # Direct submodule enable
# ... other options unchanged
```

#### Benefits

1. **Simplified Configuration**: Reduced from 4 levels to 2 levels of enable options
2. **Clearer Intent**: Direct submodule enables make it obvious which features are active
3. **Reduced Redundancy**: No more duplicate enable options for the same functionality
4. **Better Maintainability**: Less code to maintain and fewer potential conflicts

### Verification Commands

After migration, verify your configuration works:

```bash
# Validate syntax
nix flake check

# Test configuration build
nix build .#nixosConfigurations.xps.config.system.build.toplevel --dry-run

# Show flake outputs
nix flake show

# Check specific module status (examples)
systemctl status incus      # Incus service
systemctl status sshd       # SSH service
systemctl status zfs-*      # ZFS services
incus list                  # Container status
```

## [2025-01-XX] - Initial Setup

### Added
- Modular flake architecture with multi-host support
- Hardware-specific configurations (Dell XPS 13 9315)
- ZFS integration with automatic scrubbing and trimming
- Incus container and VM management with web UI
- Tailscale VPN integration
- SSH hardening with key-only authentication
- User management with proper groups and SSH keys
- Firmware update automation
- Auto-upgrade system with reboot capability

### Features
- **Hardware Support**: Dell XPS 13 9315 optimizations
- **Storage**: ZFS with automatic maintenance
- **Virtualization**: Incus with web UI and bridge networking
- **Security**: SSH key authentication, firewall configuration
- **Networking**: Bridge interfaces, Tailscale VPN
- **Management**: Auto-updates, firmware updates
- **Users**: Proper user accounts with appropriate groups

## [2025-01-XX] - Documentation Improvements

### Added
- Comprehensive verification commands in module headers
- AGENTS.md with collaboration guidelines
- CONTRIBUTING.md with workflow standards
- README.md with quick start guide
- Module structure documentation

### Features
- **Verification**: Commands to test each module's functionality
- **Workflow**: Git standards and commit conventions
- **Architecture**: Clear module organization and patterns
- **Examples**: Working code samples for common tasks
