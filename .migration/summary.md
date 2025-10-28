# NixOS Flake Migration Summary

## Current vs. Target State

### Current Issues
1. **Secrets**: Using `agenix` instead of reference-standard `sops-nix`
2. **Structure**: No `hosts/common/core/` or `hosts/common/optional/` separation
3. **Over-abstraction**: Complex `mkSystem` helper for single host (violates simplicity principle)
4. **Module Organization**: Feature-based but missing `nixos/` and `profiles/` subdirectories
5. **Hardware Config**: Nested in `hardware/` subdirectory instead of root level
6. **Lib Helpers**: Multiple helpers with unclear usage count (violates three-use rule)

### Target Architecture (from references)

```
nixos-config/
├── flake.nix                          # Explicit, simple for 1 host
├── flake.lock
├── hosts/
│   ├── common/
│   │   ├── core/                      # Required on ALL hosts
│   │   │   ├── default.nix
│   │   │   ├── nix-settings.nix
│   │   │   ├── networking.nix
│   │   │   ├── users.nix
│   │   │   └── packages.nix
│   │   └── optional/                  # Opt-in per host
│   │       ├── virtualization.nix
│   │       ├── zfs.nix
│   │       └── tailscale.nix
│   └── xps/
│       ├── default.nix               # Host-specific only
│       ├── hardware-configuration.nix
│       └── secrets.yaml              # sops-encrypted
├── modules/                           # For future growth
│   ├── nixos/
│   └── profiles/
├── secrets/
│   └── (placeholder for now)
├── .sops.yaml                        # Secrets config
└── lib/
    └── default.nix                   # Only 3+ use helpers
```

## Key Principles (from 13-key-insights.md)

1. **Optimize for reading, not writing** - Explicit over clever
2. **Three-use rule** - Inline twice, extract on third use
3. **Host-specific values never leave host directories** - IPs, hostnames in hosts/<hostname>/
4. **Module depth indicates smell** - Flatten deep chains
5. **Version lock synchronization** - One flake.lock for all hosts
6. **Test activation before switch** - Use `nixos-rebuild test`
7. **Binary caching is not optional** - Set up Cachix for multi-host

## Migration Steps

### Phase 1: Preparation (Zero Risk)

```bash
# 1. Backup current system
sudo nixos-rebuild build
git add -A && git commit -m "pre-migration checkpoint"

# 2. Create migration branch
git checkout -b migration/reference-architecture

# 3. Install required tools
nix-shell -p sops age ssh-to-age
```

### Phase 2: Generate Age Keys

```bash
# 1. Generate personal age key
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt

# Output will show:
# Public key: age1...
# SAVE THIS PUBLIC KEY

# 2. Convert SSH host key to age
cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
# Output: age1...
# SAVE THIS PUBLIC KEY
```

### Phase 3: Update .sops.yaml

Edit `.sops.yaml` created in `/home/claude/.sops.yaml`:

```yaml
keys:
  - &admin age1YOUR_PERSONAL_KEY_HERE
  - &xps age1YOUR_HOST_KEY_HERE

creation_rules:
  - path_regex: hosts/.*/secrets\.yaml$
    key_groups:
      - age:
          - *admin
          - *xps
```

### Phase 4: Directory Restructure

```bash
# Run the migration script
chmod +x /home/claude/migrate.sh
bash /home/claude/migrate.sh
```

This script will:
- Create checkpoint commit
- Create migration branch
- Restructure directories
- Copy new configuration files
- Update flake inputs
- Verify structure
- Commit changes

### Phase 5: Create Secrets

```bash
# 1. Create secrets file for xps host
sops hosts/xps/secrets.yaml

# 2. Add your secrets in YAML format:
tailscale-auth: tskey-auth-...

# 3. Save and exit - file is automatically encrypted
```

### Phase 6: Review Configuration

```bash
# 1. Verify flake structure
nix flake check --no-build

# 2. Check what files changed
git diff main..migration/reference-architecture

# 3. Review new structure
tree hosts/
tree modules/
```

### Phase 7: Test Build

```bash
# 1. Dry build (no system changes)
nixos-rebuild dry-build --flake '.#xps'

# 2. Build full configuration
nix build '.#nixosConfigurations.xps.config.system.build.toplevel'

# 3. Review what will change
nixos-rebuild dry-activate --flake '.#xps'
```

### Phase 8: Test Activation (Safe)

```bash
# Test activation WITHOUT boot menu changes
# Reboot will revert if something breaks
sudo nixos-rebuild test --flake '.#xps'

# Verify everything works:
# - SSH still accessible
# - Tailscale connected: tailscale status
# - Incus running: incus list
# - ZFS healthy: zpool status
# - Secrets accessible: ls -la /run/secrets/
```

### Phase 9: Final Switch

```bash
# Activate permanently with boot menu entry
sudo nixos-rebuild switch --flake '.#xps'

# Verify boot menu
bootctl list

# Check current generation
nixos-rebuild list-generations
```

### Phase 10: Cleanup

```bash
# Merge migration branch
git checkout main
git merge migration/reference-architecture
git branch -d migration/reference-architecture

# Optional: Remove old module structure
# Only after verifying new setup works!
```

## Rollback Procedures

### If test activation fails:
```bash
# Just reboot - test doesn't modify boot menu
sudo reboot
```

### If switch activation fails:
```bash
# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Or from boot menu:
# Select previous generation at GRUB/systemd-boot
```

### If configuration is broken:
```bash
# Revert git changes
git checkout main
sudo nixos-rebuild switch --flake '.#xps'
```

## Verification Checklist

After migration, verify:

- [ ] System boots successfully
- [ ] SSH accessible: `ssh erik@xps`
- [ ] Tailscale connected: `tailscale status`
- [ ] Incus running: `incus list`
- [ ] ZFS healthy: `zpool status`
- [ ] Secrets decrypted: `ls -la /run/secrets/`
- [ ] Firewall configured: `sudo nft list ruleset`
- [ ] Services running: `systemctl status sshd tailscaled incus`
- [ ] Automatic updates working: `systemctl status nixos-upgrade.timer`

## What Changed

### Removed
- `agenix` input and module
- `hosts/default.nix` (empty wrapper)
- `hosts/xps/hardware/` subdirectory
- Complex module structure under `modules/`
- Custom `mkSystem` helper
- Most lib helpers (moved inline or removed)

### Added
- `sops-nix` input and configuration
- `hosts/common/core/` with baseline config
- `hosts/common/optional/` with opt-in features
- `.sops.yaml` for secrets management
- Simplified, explicit `flake.nix`
- Comments explaining *why*, not *what*

### Preserved
- All functionality (SSH, Tailscale, Incus, ZFS)
- Hardware configuration
- User accounts and SSH keys
- Network configuration
- Firewall rules
- Automatic updates

## Benefits

1. **Maintainability**: Clear separation of core vs optional
2. **Scalability**: Ready to add hosts 2, 3, 4... without refactoring
3. **Simplicity**: Explicit configuration, no hidden magic
4. **Standards**: Follows community best practices from 2023-2025
5. **Bus Factor**: Another admin can understand in one sitting
6. **Testability**: Safe dry-run and test workflows
7. **Secrets**: Industry-standard sops-nix with age encryption

## Future Growth Path

When you add host #2:
```nix
# In flake.nix nixosConfigurations:
server-1 = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit self; };
  modules = [
    ./hosts/common/core
    ./hosts/server-1
    sops-nix.nixosModules.sops
  ];
};
```

At host #3, introduce helper function:
```nix
let
  mkHost = hostname: nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit self; };
    modules = [
      ./hosts/common/core
      ./hosts/${hostname}
      sops-nix.nixosModules.sops
    ];
  };
in {
  nixosConfigurations = {
    xps = mkHost "xps";
    server-1 = mkHost "server-1";
    server-2 = mkHost "server-2";
  };
}
```

## Reference Documentation

All files created follow patterns from:
- `01-introduction-and-structure.md` - Core structure
- `02-starting-minimal.md` - Single host pattern
- `05-secrets-management.md` - sops-nix setup
- `09-functional-mvp-part1.md` - Complete working example
- `10-functional-mvp-part2.md` - Bootstrap workflow
- `13-key-insights.md` - Maintainability principles

## Support

If issues arise:
1. Check `MIGRATION_PLAN.md` for detailed troubleshooting
2. Review reference docs in `00-INDEX.md` → `15-conclusion.md`
3. Use rollback procedures above
4. Verify each step in isolation

## Success Indicators

Migration successful when:
- ✅ System runs all services as before
- ✅ Configuration builds without errors
- ✅ Secrets decrypt properly
- ✅ Structure matches reference architecture
- ✅ Can explain every import to another admin
- ✅ Ready to add host #2 in 5 minutes
