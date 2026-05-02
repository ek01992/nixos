# NixOS Config Audit Report
Generated: 2026-05-02

## Executive Summary

**Baseline cold-start token load:** 4,964 words across CLAUDE.md + project rules + ECC global rules.

**Top 3 findings:**
1. `new-host.sh` template drift — both host templates are missing `home`, `shell`, and `editor` module imports that every current host uses. Any scaffold with the current script produces a broken config.
2. Four stale wiki pages — `hosts/nixxy.md`, `hosts/nixos-wsl.md`, `overview.md`, and `features/niri.md` all predate commit `8e3b6d4`, which added three new feature modules and ~20 niri keybinds.
3. Three missing wiki pages — `features/editor.md`, `features/home.md`, `features/shell.md` have no wiki coverage at all.

**Estimated token savings if all HIGH recommendations applied:** ~200 words removed from cold-start context (CLAUDE.md trim); downstream savings from fewer lookup failures.

---

## Domain A: Cold-Start Token Cost

### Findings

| File | Section | Issue | Proposed Action | Est. Token Delta |
|------|---------|-------|-----------------|-----------------|
| `CLAUDE.md` | Key inputs table (6 rows) | Duplicates `wiki/flake-inputs.md` or equivalent; inputs don't change session-to-session | Remove table; add one-line note: "See `flake.nix` for current inputs." | −90w |
| `CLAUDE.md` | Feature modules — niri paragraph (~60w) | Partially duplicates `wiki/features/niri.md`; keybind detail belongs in wiki | Trim to one line: "niri.nix — compositor + myNiri package; see `[[features/niri]]`." | −50w |
| `CLAUDE.md` | Feature modules — noctalia paragraph (~50w) | Partially duplicates `wiki/features/noctalia.md` | Trim to one line: "noctalia/noctalia.nix — bar widget package; edit noctalia.json directly." | −40w |
| `CLAUDE.md` | ECC Overrides section | Located near end of file; this section is the most important framing for session behavior | Move to immediately after "What This Is" section | 0 (reorder only) |
| ECC global rules | `code-review.md` (553w), `testing.md` (204w), `development-workflow.md` (315w) | These are globally loaded but overridden by project rules; they add cost before the override is read | No change possible here — loaded by global config. Mitigated by ECC Overrides section moving to top of CLAUDE.md. | 0 (systemic) |

**Total available savings:** ~180w from CLAUDE.md trimming alone.

**What must stay:** Common Commands (every session), Architecture section (structural reference), Skills Quick Reference table (lookup efficiency), ECC Overrides (session framing), Scaffolding section (procedural reference).

### Council Verdict — Domain A

**Token Economist:** Remove the Key inputs table (90w) and trim both Feature module paragraphs to single lines (90w combined) — total ~180w savings with zero retrieval loss since wiki covers both. The CLAUDE.md word count is 1,079; this trim brings it to ~900w without touching load-bearing sections.

**NixOS Workflow Expert:** The ECC Overrides section placement is the most impactful change here. A new session reads CLAUDE.md top-to-bottom; if overrides land on page 3, the ECC agents/testing/code-review rules fire before the override is encountered. Move overrides to immediately after "What This Is" — this prevents wasted agent invocations in every session.

**Information Architect:** Project rule files are well-calibrated: `wiki-lookup.md` (461w) is the largest and worth every word. The CLAUDE.md trim is safe because `wiki/index.md` provides the navigation layer that makes Key inputs and verbose Feature module descriptions redundant.

**Critical Senior SME:** Don't over-trim CLAUDE.md. It serves as the single-file cold-start context; wiki pages require additional Read calls to retrieve. The 180w savings are real but secondary to moving ECC Overrides earlier — that structural fix prevents agent misfire every session, which is the higher-value change.

- **Consensus:** Move ECC Overrides section earlier; trim Key inputs table and Feature module paragraphs.
- **Strongest dissent:** Critical Senior SME cautions against CLAUDE.md over-trimming — wiki lookup has latency cost; keep CLAUDE.md as the dense summary layer.
- **Recommendation:** Move ECC Overrides first. Then trim Key inputs table and condense Feature module paragraphs to single lines referencing wiki. Do not remove the Architecture section.

---

## Domain B: Wiki Structure and Retrieval Efficiency

### Wiki Lint Output (2026-05-02)

```
## Wiki Lint Report — 2026-05-02

### FIXED (auto-corrected)
- none

### WARN (flag for review)
- [missing page] wiki/features/editor.md — no coverage for modules/features/editor.nix
- [missing page] wiki/features/home.md — no coverage for modules/features/home.nix
- [missing page] wiki/features/shell.md — no coverage for modules/features/shell.nix
- [stale] modules/features/editor.nix, home.nix, shell.nix added after wiki/hosts/nixxy.md last updated
- [stale] modules/features/editor.nix, home.nix, shell.nix added after wiki/hosts/nixos-wsl.md last updated
- [stale] modules/features/editor.nix, home.nix, shell.nix added after wiki/overview.md last updated
- [stale] niri.nix updated (commit 8e3b6d4) after wiki/features/niri.md last updated; keybinds section documents only 3 of ~20 binds

### PASS
- Wikilinks: all resolve
- Sources: all paths exist
- Frontmatter: complete on all pages
- Orphans: none detected
```

### Stale Pages Table

| Page | Status | Reason |
|------|--------|--------|
| `wiki/hosts/nixxy.md` | STALE | Imports list omits `home`, `shell`, `editor` modules added in commit `8e3b6d4` |
| `wiki/hosts/nixos-wsl.md` | STALE | Same — imports list missing `home`, `shell`, `editor` |
| `wiki/overview.md` | STALE | Module graph shows only `niri.nix` and `noctalia/` under features; `home-manager` input missing |
| `wiki/features/niri.md` | STALE | Keybinds section documents 3 binds; actual module has ~20 (navigation, resize, workspace, lock, screenshot) |

### Missing Pages List

- `wiki/features/editor.md` — `flake.nixosModules.editor`; helix, `defaultEditor = true`
- `wiki/features/home.md` — `flake.nixosModules.home`; home-manager bridge, `home-manager.nixosModules.home-manager`
- `wiki/features/shell.md` — `flake.nixosModules.shell`; fish + starship, shell aliases for fish

### Structure Gap Map

```
modules/features/          wiki/features/
├── editor.nix         →   ❌ MISSING
├── home.nix           →   ❌ MISSING
├── niri.nix           →   ⚠️  STALE
├── noctalia/          →   ✅  wiki/features/noctalia.md
└── shell.nix          →   ❌ MISSING

modules/hosts/nixxy/       wiki/hosts/
├── configuration.nix  →   ⚠️  STALE (nixxy.md)
└── hardware.nix       →   ✅

modules/hosts/wsl/         wiki/hosts/
├── configuration.nix  →   ⚠️  STALE (nixos-wsl.md)
└── hardware.nix       →   ✅

modules/common.nix     →   ✅  wiki/modules/common.md (minor stale: fish alias note missing)
modules/devshells/     →   ✅  wiki/devshells/default.md
```

### Council Verdict — Domain B

**Token Economist:** Four stale pages create lookup failures: every question about host imports or niri keybinds reads a stale page, returns wrong data, then forces a source-file read — costing 2 reads where 1 should suffice. Fixing these 4 pages pays for itself immediately.

**NixOS Workflow Expert:** The 3 missing pages are each small modules (11–27 lines). All three can be stubbed with `/wiki-update` in under 5 minutes each. `wiki/features/niri.md` staleness is the most disruptive — niri is the primary graphical interface and its keybinds are queried frequently.

**Information Architect:** `wiki/overview.md` is the module graph entry point. Its staleness means any structural question starts with an incorrect picture of the feature tree. Prioritize: overview → host pages → niri → missing feature pages.

**Critical Senior SME:** The wiki structure itself is sound; this is entirely a freshness problem caused by commit `8e3b6d4` landing without a wiki sync. Going forward, the wiki-lint PostToolUse hook (Domain C) would catch this automatically.

- **Consensus:** 4 stale pages + 3 missing pages; all fixable with `/wiki-update`; prioritize overview and host pages first.
- **Strongest dissent:** None — all four roles align on priority order.
- **Recommendation:** Fix in order: (1) overview.md, (2) hosts/nixxy.md + nixos-wsl.md in parallel, (3) features/niri.md, (4) create editor/home/shell stubs.

---

## Domain C: Automation and Workflow Gaps

### Current Hooks Inventory

**All hooks disabled.** `disableAllHooks: true` is set in `~/nixos/.claude/settings.local.json` (project-level, not global). No hooks are active for this repo.

Note: This setting was found in the project-level settings file, indicating a deliberate per-repo choice. The git commit that introduced it was not investigated — **investigate before re-enabling.**

### Automation Gap Table

| Workflow | Frequency Signal | Proposed Hook Type | Trigger Condition | Prerequisite |
|----------|-----------------|-------------------|-------------------|-------------|
| nixfmt-tree after .nix edits | Every commit; manual step in git-workflow.md | PostToolUse | Edit/Write tool on `*.nix` file | Remove `disableAllHooks: true` first |
| wiki-lint after wiki edits | Every wiki update session | PostToolUse | Edit/Write tool on `wiki/**/*.md` | Remove `disableAllHooks: true` first |
| Remind to run /verification-loop | Pre-commit pattern in CLAUDE.md | Stop | Session end | Remove `disableAllHooks: true` first |

Git log shows wiki-update operations appear in 3 of the last 4 `update docs` / `update wiki` commits — this is the most repeated manual workflow in the session history.

### devShell Gap List

Current devShell (`modules/devshells/default.nix`, 37 lines): includes `claude-code-nix`, `nixfmt-tree`, `git`, `nix-diff`, and standard Nix dev tools.

Missing:
- `deadnix` — detects dead Nix code (unused bindings, unreachable options)
- `statix` — Nix antipattern linter (e.g., `with pkgs; ...`, unnecessary `rec`)

Both are available in nixpkgs and complement `nix flake check` without overlapping it.

### Council Verdict — Domain C

**Token Economist:** The nixfmt-tree PostToolUse hook eliminates a manual step with zero risk — nixfmt-tree is idempotent. The ROI is immediate. The wiki-lint hook is also high value since wiki-update sessions always follow .nix edits.

**NixOS Workflow Expert:** `disableAllHooks: true` being in the project-level settings file is the key detail. This is intentional, not accidental. Before re-enabling, run `git log -p .claude/settings.local.json` to understand why it was set. A previous hook may have been causing unintended behavior. Don't just delete the setting.

**Information Architect:** The Stop hook (reminder to run `/verification-loop`) would reduce the number of commits that skip validation. Currently the pre-commit steps in `git-workflow.md` rely entirely on the user remembering them.

**Critical Senior SME:** Hooks that fire on every Edit/Write call have a cost: they add latency and can interrupt flow when false-positive triggers occur (e.g., formatting a file that was already formatted). The nixfmt-tree hook is safe. The wiki-lint hook is heavier — consider triggering it only on Stop, not PostToolUse, to avoid mid-session interruptions.

- **Consensus:** Investigate `disableAllHooks` git history first. Then add nixfmt-tree PostToolUse hook. Consider wiki-lint on Stop rather than PostToolUse.
- **Strongest dissent:** NixOS Workflow Expert and Critical Senior SME both flag the git history investigation as mandatory before any hook changes.
- **Recommendation:** (1) `git log -p .claude/settings.local.json` to understand original reason. (2) If safe, remove `disableAllHooks: true`. (3) Add nixfmt-tree PostToolUse hook for `*.nix` writes. (4) Add wiki-lint to Stop hook. (5) Add deadnix + statix to devShell.

---

## Domain D: modules/ Structure

### Coupling Map

| Module | Imports (from within modules/) | Imported By |
|--------|-------------------------------|-------------|
| `common.nix` | none | `wsl/configuration.nix`, `nixxy/configuration.nix` |
| `features/editor.nix` | none | `wsl/configuration.nix`, `nixxy/configuration.nix` |
| `features/home.nix` | `inputs.home-manager.nixosModules.home-manager` (external) | `wsl/configuration.nix`, `nixxy/configuration.nix` |
| `features/niri.nix` | none | `nixxy/configuration.nix` |
| `features/shell.nix` | none | `wsl/configuration.nix`, `nixxy/configuration.nix` |
| `features/noctalia/noctalia.nix` | none | `nixxy/configuration.nix` (via niri.nix startup) |
| `wsl/configuration.nix` | `wsl/hardware.nix`, `nixos-wsl.default` (external), `common`, `home`, `shell`, `editor` | `wsl/default.nix` |
| `nixxy/configuration.nix` | `nixxy/hardware.nix`, `common`, `niri`, `home`, `shell`, `editor`, `noctalia` | `nixxy/default.nix` |

No cross-feature coupling detected. Zero `flake.nixosModules.*` references from within feature modules.

### Anomaly Table

| File | Lines | Issue | Recommendation |
|------|-------|-------|---------------|
| `features/shell.nix` | 27 | Shell aliases (`nrb`, `nrs`, `nfc`, `nfu`) duplicated from `common.nix` (bash) for fish | Intentional — bash aliases in `common.nix` serve non-fish sessions; document the duplication as intentional in wiki/features/shell.md |
| `modules/features/home.nix` | 21 | Acts as a bridge/adapter, not a feature — just imports the home-manager nixosModule | Low concern; the separation is clean. No action required. |

No files over 200 lines. No files over 100 lines except `nixxy/configuration.nix` at 98 lines — healthy. Dendritic pattern intact.

### Council Verdict — Domain D

**Token Economist:** Nothing in Domain D requires action. Clean structure means no wasted tokens on module archaeology.

**NixOS Workflow Expert:** The dendritic pattern is correctly implemented. Each feature module is a pure `flake.nixosModules.*` export with no inward dependencies. The `home.nix` bridge pattern is idiomatic for home-manager integration.

**Information Architect:** The bash/fish alias duplication in `common.nix` + `shell.nix` is the one structural detail that will confuse future sessions. It should be documented in `wiki/features/shell.md` when that page is created.

**Critical Senior SME:** No action needed on module structure. The config is young and clean. The only watch item is `nixxy/configuration.nix` at 98 lines — if new features are added without splitting, it could breach 200 lines. Not a problem yet.

- **Consensus:** No structural issues. Module organization is healthy.
- **Strongest dissent:** None.
- **Recommendation:** Document bash/fish alias duplication intent in the new `wiki/features/shell.md` page. No structural changes needed.

---

## Domain E: Bootstrapping Scripts

### Compliance Checklist

| Script | Check | Result | Notes |
|--------|-------|--------|-------|
| `new-feature.sh` | 1 shebang | PASS | `#!/usr/bin/env bash` |
| `new-feature.sh` | 2 set -euo pipefail | PASS | Line 2 |
| `new-feature.sh` | 3 usage() | PASS | Prints to stderr, exits 1 |
| `new-feature.sh` | 4 args validated first | PASS | Validates before file touches |
| `new-feature.sh` | 5 no clobber check | PASS | Checks target path before write |
| `new-feature.sh` | 6 git add | PASS | Stages all created files |
| `new-feature.sh` | 7 structured output | PASS | "Created:" + "Next steps:" |
| `new-feature.sh` | 8 heredoc quoting | PASS | `<<'EOF'` used throughout |
| `new-feature.sh` | 9 @PLACEHOLDER@ + sed | PASS | Uses `@NAME@` tokens |
| `new-feature.sh` | 10 template matches repo | PASS | Templates match current conventions |
| `new-devshell.sh` | 1–10 | PASS (all) | All checks pass |
| `new-host.sh` | 1 shebang | PASS | |
| `new-host.sh` | 2 set -euo pipefail | PASS | |
| `new-host.sh` | 3 usage() | PASS | |
| `new-host.sh` | 4 args validated first | PASS | |
| `new-host.sh` | 5 no clobber check | PASS | |
| `new-host.sh` | 6 git add | PASS | |
| `new-host.sh` | 7 structured output | PASS | |
| `new-host.sh` | 8 heredoc quoting | PASS | |
| `new-host.sh` | 9 @PLACEHOLDER@ + sed | PASS | |
| `new-host.sh` | **10 template matches repo** | **FAIL** | Both bare-metal and wsl configuration.nix templates generate imports for only `hardware + common` (bare-metal) or `hardware + nixos-wsl + common` (wsl). Missing: `self.nixosModules.home`, `self.nixosModules.shell`, `self.nixosModules.editor` — all three are imported by every current host. |

### Gap List

| Missing Script | Priority | Rationale |
|----------------|----------|-----------|
| `new-wiki-stub.sh` | HIGH | wiki-lint generates "no coverage" warnings but there's no tool to act on them; currently requires manual page creation |
| `new-nixos-test.sh` | LOW | NixOS test modules are uncommon in this repo; not blocking |
| `update-flake-input.sh` | LOW | `nix flake update <input>` already serves this need; no wrapper needed |

### Template Drift Table

| Script | Generated Pattern | Current Repo Pattern | Match? |
|--------|------------------|---------------------|--------|
| `new-host.sh` bare-metal | imports: `hardware`, `common` | imports: `hardware`, `niri`, `common`, `home`, `shell`, `editor` | ❌ Missing `niri`, `home`, `shell`, `editor` |
| `new-host.sh` wsl | imports: `hardware`, `nixos-wsl.default`, `common` | imports: `hardware`, `nixos-wsl.default`, `common`, `home`, `shell`, `editor` | ❌ Missing `home`, `shell`, `editor` |
| `new-feature.sh` | matches repo conventions | — | ✅ |
| `new-devshell.sh` | matches repo conventions | — | ✅ |

### Council Verdict — Domain E

**Token Economist:** The `new-host.sh` template drift is the single highest-cost finding in this audit. A broken scaffold produces a non-evaluating config; debugging why requires reading the source, the template, and the git history — easily 10+ minutes and hundreds of tokens per incident.

**NixOS Workflow Expert:** Both host templates must add `self.nixosModules.home`, `self.nixosModules.shell`, and `self.nixosModules.editor`. The bare-metal template should also consider whether `niri` should be included (likely yes, since nixxy imports it). The fix is 3–6 lines per template and takes under 10 minutes.

**Information Architect:** `new-wiki-stub.sh` fills the gap between wiki-lint "no coverage" warnings and page creation. Currently that gap requires copy-pasting frontmatter manually. A stub generator would make the wiki-lint → create loop frictionless.

**Critical Senior SME:** Fix `new-host.sh` immediately — it's the only outward-facing breakage in this audit. The other findings are documentation gaps; this one actively generates broken configurations. `new-wiki-stub.sh` is the correct Phase 1 addition to scripts/; it directly accelerates Domain B fixes.

- **Consensus:** `new-host.sh` template drift is HIGH priority — fix before next host scaffold. `new-wiki-stub.sh` is the highest-value missing script.
- **Strongest dissent:** NixOS Workflow Expert notes the bare-metal template should include `niri` import; this is a judgment call (not all bare-metal hosts will use niri) — consider making it optional with a `--wayland` flag.
- **Recommendation:** (1) Fix `new-host.sh` — add home/shell/editor to both templates. (2) Write `new-wiki-stub.sh`. (3) Add `--wayland` flag to bare-metal template for optional niri inclusion.

---

## Prioritized Recommendations

| Priority | Domain | Change | Files | Effort | Impact |
|----------|--------|--------|-------|--------|--------|
| HIGH | E | Fix `new-host.sh` template drift — add `home`, `shell`, `editor` imports to both bare-metal and wsl templates | `scripts/new-host.sh` | 15 min | Prevents broken scaffolds on every new host |
| HIGH | B | Update 4 stale wiki pages: overview, nixxy, nixos-wsl, features/niri | `wiki/overview.md`, `wiki/hosts/nixxy.md`, `wiki/hosts/nixos-wsl.md`, `wiki/features/niri.md` | 20 min | Restores 1-read lookup accuracy for most common queries |
| MED | B | Create 3 missing wiki pages: features/editor, features/home, features/shell | 3 new wiki files | 15 min | Closes wiki coverage gap from commit `8e3b6d4` |
| MED | A | Move ECC Overrides section to top of CLAUDE.md (after "What This Is") | `CLAUDE.md` | 5 min | Prevents ECC agent misfires at session start |
| MED | C | Investigate `disableAllHooks` git history; re-enable if safe; add nixfmt-tree PostToolUse hook | `.claude/settings.local.json` | 20 min | Automates mandatory pre-commit step |
| MED | E | Write `new-wiki-stub.sh` for wiki coverage gap creation | `scripts/new-wiki-stub.sh` | 30 min | Makes wiki-lint → create loop frictionless |
| LOW | A | Trim CLAUDE.md: remove Key inputs table, condense Feature module paragraphs to single lines | `CLAUDE.md` | 10 min | ~180w savings per session |
| LOW | C | Add deadnix + statix to devShell | `modules/devshells/default.nix` | 10 min | Adds Nix-specific linting to standard workflow |
| LOW | E | Add `--wayland` flag to `new-host.sh` bare-metal template for optional niri inclusion | `scripts/new-host.sh` | 20 min | More accurate scaffold for non-wayland bare-metal hosts |

---

## Appendix: Baseline Measurements

### Word counts — cold-start context

```
 1079 /home/erik/nixos/CLAUDE.md
  347 /home/erik/nixos/.claude/rules/bash-scripts.md
  127 /home/erik/nixos/.claude/rules/development-workflow.md
  267 /home/erik/nixos/.claude/rules/exploration-efficiency.md
   98 /home/erik/nixos/.claude/rules/git-workflow.md
  183 /home/erik/nixos/.claude/rules/testing.md
  461 /home/erik/nixos/.claude/rules/wiki-lookup.md
  243 /home/erik/.claude/rules/ecc/agents.md
  553 /home/erik/.claude/rules/ecc/code-review.md
  389 /home/erik/.claude/rules/ecc/coding-style.md
  315 /home/erik/.claude/rules/ecc/development-workflow.md
   88 /home/erik/.claude/rules/ecc/git-workflow.md
  105 /home/erik/.claude/rules/ecc/hooks.md
  145 /home/erik/.claude/rules/ecc/patterns.md
  220 /home/erik/.claude/rules/ecc/performance.md
  140 /home/erik/.claude/rules/ecc/security.md
  204 /home/erik/.claude/rules/ecc/testing.md
 4964 total
```

### Module size survey (lines, top 20)

```
  517 total
   98 /home/erik/nixos/modules/hosts/nixxy/configuration.nix
   74 /home/erik/nixos/modules/features/niri.nix
   64 /home/erik/nixos/modules/common.nix
   53 /home/erik/nixos/modules/hosts/nixxy/hardware.nix
   51 /home/erik/nixos/modules/hosts/wsl/hardware.nix
   45 /home/erik/nixos/modules/hosts/wsl/configuration.nix
   37 /home/erik/nixos/modules/devshells/default.nix
   27 /home/erik/nixos/modules/features/shell.nix
   21 /home/erik/nixos/modules/features/home.nix
   11 /home/erik/nixos/modules/features/noctalia/noctalia.nix
   11 /home/erik/nixos/modules/features/editor.nix
    9 /home/erik/nixos/modules/hosts/wsl/default.nix
    9 /home/erik/nixos/modules/hosts/nixxy/default.nix
    7 /home/erik/nixos/modules/parts.nix
```

### Wiki state

```
git log (last 10 commits to wiki/):
764262b update docs
da2bb95 update wiki
f78d2c6 add readme. update wiki.
39fec22 add wiki and scripts

wiki/index.md: 58 lines
```

### Scripts inventory (lines)

```
   52 /home/erik/nixos/scripts/new-devshell.sh
  161 /home/erik/nixos/scripts/new-feature.sh
  258 /home/erik/nixos/scripts/new-host.sh
  471 total
```

### Hook configuration

`~/nixos/.claude/settings.local.json`: `"disableAllHooks": true` — all hooks disabled (project-level setting).

`~/.claude/settings.json`: No `disableAllHooks` setting — global hooks would be active if project setting were removed.
