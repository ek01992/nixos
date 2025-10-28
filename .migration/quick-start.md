# Quick-Start Migration Guide

## Executive Summary

**Current**: Custom modular structure with agenix, over-abstracted for single host
**Target**: Reference-compliant architecture with sops-nix, explicit configuration

**Risk**: Low (full rollback capability, test activation before commit)
**Time**: 30-60 minutes hands-on + 15 minutes verification
**Complexity**: Medium (following step-by-step instructions)

## Prerequisites

1. ✅ Current system boots and works
2. ✅ Git repository with clean working tree
3. ✅ SSH access to host (for verification after changes)
4. ✅ Reviewed MIGRATION_PLAN.md and MIGRATION_SUMMARY.md

## Step-by-Step Execution

### Step 1: Preparation (5 minutes)

```bash
# Backup and checkpoint
sudo nixos-rebuild build
git add -A && git commit -m "pre-migration: working state checkpoint"

# Install tools
nix-shell -p sops age ssh-to-age

# Create migration branch
git checkout -b migration/reference-architecture
```

### Step 2: Generate Age Keys (5 minutes)

```bash
# Personal age key
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
# Output: Public key: age1xxxxxxxxx
# SAVE THIS KEY

# Convert SSH host key to age
cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
# Output: age1yyyyyyyyy
# SAVE THIS KEY
```

### Step 3: Run Migration Script (10 minutes)

```bash
# Execute automated migration
cd /path/to/your/nixos-config
chmod +x /home/claude/migrate.sh
bash /home/claude/migrate.sh
```

This creates:
- New directory structure
- Core and optional modules
- Simplified flake.nix
- .sops.yaml template

### Step 4: Configure Secrets (10 minutes)

```bash
# 1. Update .sops.yaml with your age keys
vim .sops.yaml
# Replace age1... placeholders with keys from Step 2

# 2. Create secrets file
sops hosts/xps/secrets.yaml

# 3. Add secrets in YAML format:
# tailscale-auth: tskey-auth-xxxxxxxxxxxxx
# Save and exit - automatically encrypted

# 4. Verify encryption
cat hosts/xps/secrets.yaml
# Should show encrypted content, not plaintext
```

### Step 5: Update Host Config (5 minutes)

```bash
# Edit hosts/xps/default.nix
vim hosts/xps/default.nix

# Update line 87:
system.autoUpgrade.flake = "github:YOUR-USERNAME/nixos-config#xps";
# Replace YOUR-USERNAME with your GitHub username
```

### Step 6: Verify Configuration (10 minutes)

```bash
# 1. Flake structure valid
nix flake check --no-build

# 2. Configuration builds
nix build '.#nixosConfigurations.xps.config.system.build.toplevel'

# 3. Review what will change
nixos-rebuild dry-build --flake '.#xps'
nixos-rebuild dry-activate --flake '.#xps'

# 4. Check file structure
tree -L 3 hosts/
```

### Step 7: Test Activation (10 minutes)

```bash
# Non-persistent test (reboot reverts if broken)
sudo nixos-rebuild test --flake '.#xps'

# Immediately verify critical services:
systemctl status sshd tailscaled incus
zpool status
tailscale status
incus list
ls -la /run/secrets/

# If everything works, proceed
# If issues, reboot to revert
```

### Step 8: Final Switch (5 minutes)

```bash
# Activate permanently with boot menu entry
sudo nixos-rebuild switch --flake '.#xps'

# Verify bootloader
bootctl list

# Check generation
nixos-rebuild list-generations
```

### Step 9: Cleanup (5 minutes)

```bash
# Merge migration
git checkout main
git merge migration/reference-architecture
git branch -d migration/reference-architecture

# Push to remote
git push origin main

# Clean old generations (optional)
sudo nix-collect-garbage --delete-older-than 7d
```

## Verification Checklist

After migration:

### Critical Services
- [ ] SSH: `ssh erik@xps`
- [ ] Tailscale: `tailscale status`
- [ ] Incus: `incus list`
- [ ] ZFS: `zpool status`

### Configuration
- [ ] Secrets: `ls -la /run/secrets/`
- [ ] Firewall: `sudo nft list ruleset`
- [ ] Services: `systemctl status sshd tailscaled incus`
- [ ] Updates: `systemctl status nixos-upgrade.timer`

### Structure
- [ ] Core modules: `tree hosts/common/core/`
- [ ] Optional modules: `tree hosts/common/optional/`
- [ ] Host config: `cat hosts/xps/default.nix` (< 100 lines)
- [ ] Flake: `cat flake.nix` (< 50 lines, explicit)

## Rollback Procedures

### Test failed:
```bash
# Just reboot
sudo reboot
```

### Switch failed:
```bash
# Rollback
sudo nixos-rebuild switch --rollback
```

### Configuration broken:
```bash
# Revert git
git checkout main
sudo nixos-rebuild switch --flake '.#xps'
```

## Common Issues

### "sops: Failed to decrypt"
**Cause**: Age keys not configured properly
**Fix**:
```bash
# Verify keys in .sops.yaml match generated keys
cat ~/.config/sops/age/keys.txt  # Check personal key
cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age  # Check host key
# Update .sops.yaml if mismatched
```

### "attribute 'xyz' missing"
**Cause**: Import path incorrect
**Fix**: Check imports in `hosts/xps/default.nix`:
```nix
imports = [
  ./hardware-configuration.nix
  ../common/optional/virtualization.nix  # Not ../../common/...
  ../common/optional/zfs.nix
  ../common/optional/tailscale.nix
];
```

### "bridge externalbr0 not found"
**Cause**: Bridge name mismatch
**Fix**: Verify in `hosts/xps/default.nix`:
```nix
networking.bridges.externalbr0 = {
  interfaces = ["enp0s20f0u6u1i5"];  # Your actual interface
};
```

## Next Steps

### Immediate (After Migration)
1. Test all services for 24 hours
2. Verify secrets decrypt properly
3. Confirm automatic updates work
4. Update documentation

### Short Term (1-2 weeks)
1. Set up Cachix for binary caching
2. Add CI/CD with GitHub Actions
3. Document host-specific decisions
4. Create recovery procedures

### Long Term (As Needed)
1. Add host #2 (server, VM, etc.)
2. Extract common patterns (at 3rd use)
3. Create profile modules (workstation, server)
4. Implement NixOS tests for critical services

## Success Metrics

✅ **Migration Successful** when:
1. All services running as before
2. Configuration < 150 lines per host
3. Can add host #2 in < 10 minutes
4. Another admin understands structure in < 30 minutes
5. No agenix references remain
6. Secrets managed via sops-nix
7. Core config works unchanged on any future host

## Resources

### Created Files (in /home/claude/)
- `MIGRATION_PLAN.md` - Detailed phase-by-phase plan
- `MIGRATION_SUMMARY.md` - Comprehensive overview
- `LIB_HELPER_AUDIT.md` - Three-use rule analysis
- `migrate.sh` - Automated migration script
- `hosts/common/core/*` - Core modules
- `hosts/common/optional/*` - Optional modules
- `flake.nix` - Simplified flake
- `.sops.yaml` - Secrets configuration

### Reference Documentation
- Start: `00-INDEX.md`
- Core: `01-introduction-and-structure.md`
- Secrets: `05-secrets-management.md`
- MVP: `09-functional-mvp-part1.md`, `10-functional-mvp-part2.md`
- Insights: `13-key-insights.md`

### External Links
- NixOS Options: https://search.nixos.org/options
- sops-nix: https://github.com/Mic92/sops-nix
- Age: https://age-encryption.org/

## Questions or Issues?

1. Review `MIGRATION_SUMMARY.md` for detailed troubleshooting
2. Check reference docs `00-INDEX.md` → `15-conclusion.md`
3. Use rollback procedures if stuck
4. Test changes in VM first if uncertain

**Remember**: Every step is reversible. Take your time, verify each phase.
