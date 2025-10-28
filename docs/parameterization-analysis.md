# Parameterization Analysis: Complete Module Review

*Archived analysis from parameterization-guide.md findings*

## Executive Summary

This document captures the complete analysis of module parameterization requirements and implementation patterns for the NixOS flake architecture.

## Core Principle

**"Everything should be configurable with good defaults, unless explicitly proven unnecessary"**

Every module should follow this pattern:
```nix
options.myFeature = {
  enable = mkEnableOption "feature";
  setting = mkOption {
    type = types.str;
    default = "sensible-default";
    description = "Clear explanation of what this does and when to change it";
    example = "alternative-value";
  };
};
```

## Module-by-Module Analysis

### 1. Core Networking ✅ EXCELLENT

**Location**: `hosts/common/core/networking.nix`

**Current State**: Perfect implementation
- ✅ No coupling to optional modules
- ✅ Only handles SSH + fundamentals
- ✅ Uses proper options pattern
- ✅ Clear descriptions and examples

**Options Available**:
- `disableIpv6Privacy` - default: true
- `useSystemdNetworkd` - default: true
- `useNftables` - default: true
- `defaultFirewallPorts` - default: [22]

**Pattern**: Core modules should follow this exact pattern.

### 2. Tailscale Module ✅ EXCELLENT

**Location**: `hosts/common/optional/tailscale.nix`

**Current State**: Perfect implementation
- ✅ Fully parameterized
- ✅ Self-contained firewall rules
- ✅ Graceful secret handling
- ✅ Non-blocking behavior

**Options Available**:
- `useAuthKeyFile` - default: true
- `extraUpFlags` - default: []
- `trustInterface` - default: true

**Pattern**: Optional modules should follow this exact pattern.

### 3. SSH Service ✅ EXCELLENT

**Location**: `modules/services/ssh/default.nix`

**Current State**: Gold standard implementation
- ✅ Perfect parameterization
- ✅ Clear descriptions
- ✅ Good defaults
- ✅ No changes needed

**Pattern**: All service modules should follow this pattern.

### 4. ZFS Service ✅ IMPROVED

**Location**: `modules/services/zfs/default.nix`

**Previous State**: Basic enable flags, hardcoded schedules

**Current State**: Fully parameterized
- ✅ `autoScrub.interval` - default: "weekly"
- ✅ `autoScrub.pools` - default: [] (all pools)
- ✅ `trim.interval` - default: "weekly"
- ✅ Clear descriptions explaining when to change defaults

**Usage Example**:
```nix
myServices.zfs = {
  enable = true;
  autoScrub = {
    interval = "monthly";  # Less frequent for large pools
    pools = ["tank"];      # Only scrub production pool
  };
};
```

### 5. Virtualization Module ✅ IMPROVED

**Location**: `modules/virtualization/incus/preseed/default.nix`

**Previous State**: Basic options, manual firewall rules in host config

**Current State**: Fully automated
- ✅ `trustedUsers` - default: ["erik"]
- ✅ `internalNetwork.ipv4Address` - default: "auto"
- ✅ `externalNetwork.ipv4Address` - default: "auto"
- ✅ Automatic firewall trust for bridges
- ✅ User group management

**Key Improvement**: Module now handles firewall trust automatically, removing need for manual host config rules.

## Implementation Patterns

### Standard Option Pattern

```nix
options.myFeature = {
  enable = mkEnableOption "feature description" // { default = true; };

  setting = mkOption {
    type = types.str;
    default = "sensible-default";
    description = ''
      Clear explanation of what this does.
      When to change: specific use cases.
      Impact: what breaks if wrong.
    '';
    example = "alternative-value";
  };
};
```

### Module Isolation Pattern

**Core Modules**:
```nix
# ✅ CORRECT: Core handles only fundamentals
networking.firewall.allowedTCPPorts = [22];  # SSH only
# No references to optional modules
```

**Optional Modules**:
```nix
# ✅ CORRECT: Module adds its own firewall rules
networking.firewall.trustedInterfaces = ["tailscale0"];
# Self-contained, only affects system when imported
```

**Host Configs**:
```nix
# ✅ CORRECT: Only physical hardware + imports
imports = [
  ../common/optional/tailscale.nix
  ../common/optional/virtualization.nix
];
# No manual firewall rules - modules handle this
```

### Non-Blocking Secrets Pattern

```nix
# ✅ CORRECT: Service works with or without secret
services.tailscale = {
  enable = true;

  authKeyFile = lib.mkIf (
    cfg.useAuthKeyFile &&
    (config.sops.secrets ? tailscale-auth)
  ) config.sops.secrets.tailscale-auth.path;
};
```

**Behavior**:
- Secret configured → Automated authentication
- Secret missing → Service starts, requires manual `sudo tailscale up`
- System builds either way → Non-blocking ✓

## Anti-Patterns Identified

### 1. Core Coupling to Optional ❌

**Problem**:
```nix
# WRONG: Core checking optional module state
trustedInterfaces = lib.optionals (config.services.tailscale.enable or false) [
  "tailscale0"
];
```

**Fix**: Modules manage their own concerns independently.

### 2. Hardcoded Values ❌

**Problem**:
```nix
# BAD: No option, hardcoded
config.services.myapp.port = 8080;
```

**Fix**: Every setting gets an option with good defaults.

### 3. Missing Descriptions ❌

**Problem**:
```nix
# BAD: No guidance
port = mkOption { type = types.int; default = 8080; };
```

**Fix**: Clear descriptions explaining when to change.

## Implementation Roadmap

### Phase 1: Critical Fixes ✅ COMPLETED
- Core networking decoupled from optional modules
- Modules handle their own firewall rules
- Secrets non-blocking pattern implemented

### Phase 2: Module Enhancements ✅ COMPLETED
- ZFS module: Added scheduling/pool options
- Virtualization module: Added automation and user management
- All modules follow standard option pattern

### Phase 3: Documentation ✅ COMPLETED
- Cursor rules created for parameterization patterns
- Module isolation architecture documented
- Secrets non-blocking pattern documented

## Verification Commands

### Module Validation
```bash
# Check syntax
nix flake check --no-build

# Test build
nixos-rebuild dry-build --flake .#xps

# Verify networking
sudo ./scripts/network-verify.sh
```

### Service-Specific Checks
```bash
# ZFS
zpool status
systemctl status zfs-scrub@tank

# Virtualization
incus list
nft list ruleset | grep -E "internalbr|externalbr"

# Tailscale
tailscale status
systemctl status tailscaled
```

## Success Metrics

- ✅ All modules follow standard option pattern
- ✅ Core modules have no optional module dependencies
- ✅ Optional modules are self-contained
- ✅ Services work with or without secrets
- ✅ Host configs only specify hardware + imports
- ✅ System builds successfully with all changes

## Future Considerations

### When Adding New Modules
1. Follow SSH module pattern for services
2. Follow networking module pattern for core functionality
3. Follow Tailscale pattern for optional features
4. Always include enable option with sensible default
5. Document when to customize each option

### When Scaling Architecture
- **1-3 hosts**: Explicit configs (current state)
- **3-5 hosts**: Consider mkHost helper
- **5-10 hosts**: Metadata-driven config
- **10+ hosts**: Deployment tooling

## Conclusion

The parameterization analysis identified key improvements needed in the module architecture. All critical issues have been resolved:

1. **Module Isolation**: Core modules no longer depend on optional module state
2. **Parameterization**: All modules follow standard option pattern
3. **Automation**: Modules handle their own concerns (firewall rules, user groups)
4. **Documentation**: Patterns captured in cursor rules for future reference

The architecture now follows the "Optional Means Optional" principle with proper separation of concerns and comprehensive parameterization.

---

*This analysis was conducted as part of integrating parameterization findings into the NixOS flake architecture. All recommendations have been implemented and verified.*
