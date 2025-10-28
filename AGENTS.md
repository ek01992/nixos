# NixOS Flake Architecture Navigation

**Purpose**: Solo sysadmin managing AWS/Azure with NixOS flakes. 1 host → N hosts without refactoring.

## Quick Reference Map

**Start Here**:
- Lines 15-88: Directory structure (3-tier: core/optional/hosts)
- Lines 90-155: Minimal single-host pattern
- Lines 510-650: Complete working MVP with all files

**Scaling Triggers**:
- 3-5 hosts → Lines 157-195 (mkHost generator)
- 5-10 hosts → Lines 197-230 (metadata-driven config)
- 10+ hosts → Lines 232-235 (deployment tooling)

**Anti-Patterns** (Lines 237-285):
- Module depth >3 levels
- Magic derivations sans comments
- Host config mixed with shared modules
- Lib functions for single use
- Fighting flake.lock

**Critical Integrations**:
- Secrets (sops-nix): Lines 287-385
- Testing workflow: Lines 387-468
- Build optimization: Lines 470-508

**Decision Points** (Lines 652-735):
- Explicit vs DRY
- Flat vs hierarchical modules  
- Single vs multiple flake.lock files

## Token-Efficient Lookups

**Q: First-time setup?** → Lines 510-650 (MVP) + Lines 742-795 (initialization)
**Q: Adding second host?** → Lines 797-830 (growth pattern)
**Q: Slow rebuilds?** → Lines 470-508 (optimization)
**Q: Which anti-pattern am I hitting?** → Lines 237-285
**Q: When to abstract?** → Lines 157-235 (scaling patterns) + Lines 837-845 (3-use rule)
**Q: Secrets setup?** → Lines 287-385
**Q: Pre-deploy checklist?** → Lines 797-853

## Core Principles (Lines 837-885)

1. **Maintainability** > Cleverness
2. **3-use rule**: Inline twice, extract third time
3. **Host-specific values** never escape `hosts/<hostname>/`
4. **Module depth** ≤2 levels
5. **Test before switch**: `nixos-rebuild test`

## File Template Locations

- `flake.nix`: Lines 512-540
- `hosts/common.nix`: Lines 542-618
- `hosts/<hostname>/default.nix`: Lines 620-650
- `hardware-configuration.nix`: Lines 652-678
- `.sops.yaml`: Lines 322-348

## Common Tasks

**Verify changes**: Lines 797-853
**Update inputs**: Lines 869-885
**Add optional module**: Lines 832-853
**Deploy remotely**: Lines 450-468
**Run tests**: Lines 417-448

---

*Pattern: Start explicit (1-3 hosts), abstract on pain (3+ hosts), never exceed 3 levels depth.*
