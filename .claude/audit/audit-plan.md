# NixOS Config Optimization — Implementation Plan
Generated: 2026-05-02
Source: .claude/audit/audit-report.md

---

## Phase 1: Quick Wins (≤30 min each)

- [x] **Fix `new-host.sh` template drift** | `scripts/new-host.sh` | Add `self.nixosModules.home`, `self.nixosModules.shell`, `self.nixosModules.editor` to both the bare-metal and wsl configuration.nix templates. Expected delta: prevents every future `new-host.sh` scaffold from producing a broken config.

- [x] **Update `wiki/overview.md`** | `wiki/overview.md` | Add `editor.nix`, `home.nix`, `shell.nix` to the module graph; add `home-manager` to the flake inputs section. Use `/wiki-update modules/features/editor.nix modules/features/home.nix modules/features/shell.nix`. Expected delta: module graph accurate again.

- [x] **Update host wiki pages** | `wiki/hosts/nixxy.md`, `wiki/hosts/nixos-wsl.md` | Add `home`, `shell`, `editor` to the imports list for both hosts. Use `/wiki-update modules/hosts/nixxy/configuration.nix modules/hosts/wsl/configuration.nix`. Expected delta: host import queries resolve correctly in 1 read.

- [x] **Update `wiki/features/niri.md`** | `wiki/features/niri.md` | Expand keybinds section to document all ~20 binds (navigation, resize, workspace switching, lock, screenshot). Use `/wiki-update modules/features/niri.nix`. Expected delta: niri keybind queries no longer require source-file fallback.

- [x] **Move ECC Overrides section to top of CLAUDE.md** | `CLAUDE.md` | Relocate the "ECC Overrides (NixOS-specific)" section to immediately after "What This Is", before Common Commands. Expected delta: prevents ECC agent misfires at session start.

---

## Phase 2: Medium Effort (1–2 hours each)

- [x] **Create 3 missing wiki pages** | `wiki/features/editor.md`, `wiki/features/home.md`, `wiki/features/shell.md` | Use `/wiki-update` for each. For `shell.md`, document the intentional bash/fish alias duplication (common.nix handles bash; shell.nix handles fish — both hosts import both). Expected delta: full wiki coverage for all feature modules.

- [x] **Trim CLAUDE.md** | `CLAUDE.md` | (a) Remove Key inputs table (6 rows, ~90w) — replace with: "See `flake.nix` for current inputs." (b) Condense Feature modules section: trim niri paragraph to one line referencing `[[features/niri]]`; trim noctalia paragraph to one line. Expected delta: ~180w reduction per session.

- [x] **Investigate and re-enable hooks** | `.claude/settings.local.json` | Run `git log -p .claude/settings.local.json` to understand why `disableAllHooks: true` was set. If no blocking reason, remove the setting. Then add a PostToolUse hook for `nixfmt-tree` on `*.nix` file writes. Consider adding wiki-lint to the Stop hook. Expected delta: eliminates manual nixfmt-tree step; catches wiki staleness automatically.

- [x] **Write `new-wiki-stub.sh`** | `scripts/new-wiki-stub.sh` | Script that accepts a source .nix path and creates a corresponding wiki page stub with correct frontmatter (`title`, `type`, `updated`, `sources`). Should follow bash-scripts.md standards, use `<<'EOF'` heredoc quoting, validate target does not exist, and `git add` the new file. Expected delta: wiki-lint "no coverage" warnings become 1-command fixes.

---

## Phase 3: Structural Changes (requires /verification-loop)

- [ ] **Add deadnix + statix to devShell** | `modules/devshells/default.nix` | Add `pkgs.deadnix` and `pkgs.statix` to the devShell packages list. Run `nix flake check` + `nixos-rebuild build` on both hosts after. Risk: LOW — additive change, no functional impact. Expected delta: Nix-specific linting available in standard workflow.

- [ ] **Add `--wayland` flag to `new-host.sh` bare-metal template** | `scripts/new-host.sh` | Make niri import conditional on a `--wayland` flag in the bare-metal template. Without the flag, bare-metal template generates `hardware + common + home + shell + editor` only. With `--wayland`, also adds `niri`. Risk: LOW — additive flag, existing behavior preserved. Expected delta: accurate scaffold for non-wayland bare-metal hosts.

---

## Validation Gates

After each phase:
1. `nix flake check`
2. `/wiki-lint` (for any wiki changes)
3. `/verification-loop` (before any commit)
