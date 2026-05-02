---
name: nixos-audit
description: >
  Comprehensive audit-only review of the NixOS flake config. Covers cold-start token
  cost, wiki structure, automation gaps, module coupling, and bootstrapping scripts.
  Invokes /everything-claude-code:council (with custom roles) once per domain.
  Produces .claude/audit/audit-report.md and .claude/audit/audit-plan.md.
  No file changes are made during the session.
---

# NixOS Audit

## When to Use

Trigger: `/nixos-audit`

- Before a major refactoring session (establishes baseline)
- When sessions feel slow or token-heavy
- When wiki feels stale or hard to navigate
- When skills or scripts feel out of sync with current repo conventions
- Periodically (quarterly) to catch drift

## When NOT to Use

- For implementing found issues — execute the produced `audit-plan.md` in a separate session
- For single-file questions — use wiki lookup or `/nixos-patterns` directly
- For package/option lookups — use the `nixos` MCP tool
- When you only need one domain — run `/wiki-lint` or `/nixos-patterns` directly instead

---

## Mode: AUDIT ONLY

**No file changes are made during this session.**

The session ends by writing two artifacts:

| Artifact | Path | Purpose |
|---|---|---|
| Report | `.claude/audit/audit-report.md` | Findings + council verdicts per domain |
| Plan | `.claude/audit/audit-plan.md` | Prioritized task list for next implementation session |

Both files are written only after all five domains and all five council sessions are
complete. Do not write partial output mid-session.

---

## Output Templates

Define these templates mentally before starting — they govern all output.

### audit-report.md structure
```
# NixOS Config Audit Report
Generated: YYYY-MM-DD

## Executive Summary
- Baseline token counts (from Preparation)
- Top 3 findings per domain
- Total estimated token savings if all HIGH recommendations applied

## Domain A: Cold-Start Token Cost
[findings table]
[council verdict]

## Domain B: Wiki Structure
[stale pages table]
[structure gap map]
[council verdict]

## Domain C: Automation Gaps
[hooks inventory — note: currently all disabled via disableAllHooks: true]
[automation gap table]
[devShell gap list]
[council verdict]

## Domain D: modules/ Structure
[coupling map]
[anomaly table]
[council verdict]

## Domain E: Bootstrapping Scripts
[compliance checklist]
[gap list]
[template drift table]
[council verdict]

## Prioritized Recommendations
| Priority | Domain | Change | Files | Effort | Impact |
| HIGH     | ...    | ...    | ...   | ...    | ...    |

## Appendix: Baseline Measurements
[raw output from Preparation phase]
```

### audit-plan.md structure
```
# NixOS Config Optimization — Implementation Plan
Generated: YYYY-MM-DD
Source: .claude/audit/audit-report.md

## Phase 1: Quick Wins (≤30 min each)
- [ ] Task | File(s) | Expected delta

## Phase 2: Medium Effort (1–2 hours each)
- [ ] Task | File(s) | Expected delta

## Phase 3: Structural Changes (requires /verification-loop)
- [ ] Task | File(s) | Risk | Prerequisite

## Validation Gates
After each phase:
- nix flake check
- /wiki-lint  (for any wiki changes)
- /verification-loop  (before any commit)
```

---

## Preparation Phase

Run all of the following in a **single parallel batch** before starting any domain.
Save the complete output — it becomes the Appendix in `audit-report.md`.

```bash
# Token / word baseline
wc -w ~/nixos/CLAUDE.md ~/nixos/.claude/rules/*.md ~/.claude/rules/ecc/*.md

# Module size survey
find ~/nixos/modules -name "*.nix" | xargs wc -l | sort -rn | head -20

# Wiki state
git -C ~/nixos log --oneline -10 -- wiki/
wc -l ~/nixos/wiki/index.md

# Scripts inventory
wc -l ~/nixos/scripts/*.sh

# Current hook config (both levels)
cat ~/nixos/.claude/settings.local.json
cat ~/.claude/settings.json
```

---

## Domain A: Cold-Start Token Cost

**Goal:** Minimize tokens consumed before Claude is productive in a new session.

### Reads (parallel)
- `~/nixos/CLAUDE.md`
- All `~/nixos/.claude/rules/*.md`
- All `~/.claude/rules/ecc/*.md`
- `~/.claude/MEMORY.md`
- `~/nixos/wiki/index.md`

### Audit Questions
1. What content in `CLAUDE.md` duplicates a wiki page verbatim or substantially?
2. What content in project `.claude/rules/` duplicates global `~/.claude/rules/ecc/`?
3. What `MEMORY.md` entries are already covered by `CLAUDE.md` or a wiki page?
4. Which `CLAUDE.md` sections are referenced in every session vs. rarely?
5. Could `wiki/index.md` replace or supplement any `CLAUDE.md` section?

### Output Format
```
| File | Section | Issue | Proposed Action | Est. Token Delta |
```

---

## Domain B: Wiki Structure and Retrieval Efficiency

**Goal:** Any repo question resolves in ≤2 Read calls with no ambiguity.

### Step 1 — Delegate to wiki-lint
Run `/wiki-lint` and capture its full output. Do **not** re-implement stale, orphan,
broken-link, or frontmatter checks manually — wiki-lint already covers these.

### Step 2 — Reads (parallel)
- `~/nixos/wiki/wiki-schema.md`
- `~/nixos/wiki/overview.md`
- All pages linked in `wiki/index.md` (parallel Read calls)

### Step 3 — Bash
```bash
# Compare modules/ tree vs wiki/ tree for structural gaps
find ~/nixos/modules -name "*.nix" | sed 's|.*/modules/||' | sort
find ~/nixos/wiki -name "*.md" | sed 's|.*/wiki/||' | sort
# Check wiki/modules/ coverage
ls ~/nixos/wiki/modules/ 2>/dev/null || echo "MISSING: wiki/modules/"
```

### Audit Questions
1. Does every `wiki/index.md` entry have a one-line hook that answers "what is this"?
2. Which `modules/` files have no corresponding wiki page? (compare tree outputs above)
3. Are there wiki pages that could be merged without losing retrieval precision?
4. Does the `wiki/` directory structure mirror `modules/` exactly?

### Output Format
- **Stale pages table** (sourced from wiki-lint output): `| Page | Status | Source Last Commit |`
- **Missing pages list**
- **Structure gap map**: two-column diff of modules/ tree vs wiki/ tree

---

## Domain C: Automation and Workflow Gaps

**Goal:** Identify manual workflows repeated across sessions that should be automated.

### Critical Context
`disableAllHooks: true` is set in `.claude/settings.local.json`. **All hook
recommendations must include the prerequisite:** "remove `disableAllHooks: true`
from `.claude/settings.local.json` first."

### Reads (parallel)
- `~/nixos/.claude/settings.local.json` (already read in Preparation — reuse)
- `~/.claude/settings.json` (already read in Preparation — reuse)
- `~/nixos/wiki/log.md`
- All files in `~/nixos/modules/devshells/`

The `CLAUDE.md` Skills Quick Reference table was already read in Domain A — reuse it.

### Bash
```bash
# Identify repeated operations in recent history
git -C ~/nixos log --oneline -30 -- modules/ wiki/
# Find module edits that may have missed a wiki-update
git -C ~/nixos log --oneline -30 --diff-filter=M -- modules/
```

### Audit Questions
1. What hooks currently exist in settings? (Answer: none — all disabled)
2. What operations appear 3+ times in `wiki/log.md` or the git log above?
3. Which skills in the `CLAUDE.md` Quick Reference table have no automatic trigger?
4. Should a PostToolUse hook on `.nix` file writes trigger `nixfmt-tree` automatically?
5. What tools are present in the devShell vs. what the full workflow actually requires?

### Output Format
- **Current hooks inventory** (note: all disabled via `disableAllHooks: true`)
- **Automation gap table**: `| Workflow | Frequency Signal | Proposed Hook Type | Trigger Condition | Prerequisite |`
- **devShell gap list**

---

## Domain D: modules/ Structure

**Goal:** Module organization matches the dendritic pattern with minimal coupling.

Reference `/nixos-patterns` for the dendritic pattern definition and flake-parts
module header conventions — do not re-explain them here.

### Reads (parallel)
- `~/nixos/modules/common.nix`
- `~/nixos/modules/parts.nix`
- `~/nixos/modules/hosts/wsl/configuration.nix`
- `~/nixos/modules/hosts/nixxy/configuration.nix`
- `~/nixos/modules/features/niri.nix`
- `~/nixos/modules/features/noctalia/noctalia.nix`

### Bash
```bash
# Full module tree with line counts
find ~/nixos/modules -name "*.nix" | xargs wc -l | sort -rn

# Cross-module import coupling scan
grep -r "flake\.nixosModules\." ~/nixos/modules/ --include="*.nix" -l
grep -rn "flake\.nixosModules\." ~/nixos/modules/ --include="*.nix"
```

### Audit Questions
1. Does `common.nix` contain anything host-specific or conditional on host identity?
2. Do any feature modules import each other (cross-feature coupling)?
3. Has `parts.nix` grown beyond its intended role (setting `systems`)?
4. Are any `.nix` files over 200 lines and candidates for splitting?
5. Is the `flake.nixosModules.<name>` naming pattern consistent across all modules?

### Output Format
- **Coupling map**: `| Module | Imports | Imported By |`
- **Anomaly table**: `| File | Lines | Issue | Recommendation |`

---

## Domain E: Bootstrapping Scripts

**Goal:** `scripts/` covers all common scaffolding operations and each script
meets the `bash-scripts.md` standard.

### Reads (parallel)
- `~/nixos/scripts/new-feature.sh`
- `~/nixos/scripts/new-host.sh`
- `~/nixos/scripts/new-devshell.sh`
- `~/nixos/.claude/rules/bash-scripts.md`

### Compliance Checklist (apply to each script)

Map each script against every requirement in `bash-scripts.md`:

| Check | Requirement |
|---|---|
| 1 | `#!/usr/bin/env bash` shebang present |
| 2 | `set -euo pipefail` on second line |
| 3 | `usage()` function present, prints to stderr, exits 1 |
| 4 | All required args validated before any file is touched |
| 5 | Target path existence checked before writing (fail fast, no clobber) |
| 6 | `git add` called on all created files at end |
| 7 | "Created: / Next steps:" structured output printed |
| 8 | Nix template heredocs use `<<'EOF'` (quoted delimiter) |
| 9 | Template substitutions use `@PLACEHOLDER@` + `sed -i`, not bash `${}` expansion |
| 10 | Generated templates match current repo conventions (cross-check vs actual `modules/`) |

### Gap Analysis

Evaluate whether a script is missing for any of these operations:
- New wrapped package (standalone, not tied to a feature module)
- New `nixosTest` module
- Updating a single named flake input
- New wiki page stub creation

### Output Format
- **Compliance checklist**: `| Script | Check # | Pass/Fail | Notes |`
- **Gap list** with priority (HIGH/MED/LOW)
- **Template drift table**: `| Script | Generated Pattern | Current Repo Pattern | Match? |`

---

## Council Phase

After **all five domains** are audited and their findings tables are complete, invoke
`/everything-claude-code:council` once per domain.

### Custom Role Override (apply to every council session)

Replace the council's default four voices with:

| Role | Responsibility |
|---|---|
| **Token Economist** | Evaluates cost/benefit of every recommendation against token savings. Challenges anything that adds context without proportional value. |
| **NixOS Workflow Expert** | Flags anything that breaks flake-parts, import-tree, or NixOS conventions. Validates recommendations are idiomatic. |
| **Information Architect** | Evaluates retrieval efficiency, structure clarity, and documentation coverage. Optimizes for ≤2-call resolution. |
| **Critical Senior SME and Developer** | Challenges assumptions, identifies what the audit missed, asks "what breaks if we do this?", devil's advocate, assesses practical implementation risk. |

### Per-Domain Council Questions

Provide the domain's findings table as context, the role overrides above, and the
question below. Keep the context compact — pass findings tables, not conversation history.

**Council A:**
> "Given these redundancies in CLAUDE.md, rules, and MEMORY.md — what is the minimum
> viable cold-start context that preserves all actionable guidance? What is safe to
> remove vs. what must stay?"

**Council B:**
> "Given these wiki gaps and stale pages — what structural changes make every lookup
> resolve in ≤2 Read calls? Is the current index.md format optimal, or should it
> be restructured?"

**Council C:**
> "Given that `disableAllHooks: true` is currently set — which automation gaps are
> highest priority once hooks are re-enabled? What is the risk of re-enabling hooks
> in this repo?"

**Council D:**
> "Given this coupling map and anomaly list — which structural issues pose the greatest
> risk as the config grows? What is the recommended priority order for addressing them?"

**Council E:**
> "Given this compliance checklist and gap analysis — which script deficiencies pose
> the highest risk of generating broken or non-idiomatic modules? What missing script
> provides the most value?"

### Recording Verdicts

Record each council's output in `audit-report.md` using the standard format:

```
### Council Verdict — Domain [X]

**Token Economist:** [1–2 sentence position]
**NixOS Workflow Expert:** [1–2 sentence position]
**Information Architect:** [1–2 sentence position]
**Critical Senior SME:** [1–2 sentence position]

- **Consensus:** [where all four align]
- **Strongest dissent:** [most important disagreement]
- **Recommendation:** [synthesized path forward]
```

---

## Writing Output Artifacts

After all five councils are recorded:

1. Create `.claude/audit/` directory if it does not exist
2. Write `.claude/audit/audit-report.md` using the template defined above
3. Write `.claude/audit/audit-plan.md` using the template defined above

Sort the Prioritized Recommendations table by impact ÷ effort (highest ratio first).
Tasks in Phase 1 of the plan should each be completable in under 30 minutes.

---

## Anti-Patterns

- Making any file changes during the audit session
- Running `nixos-rebuild` or `nix build` (read-only session only)
- Re-implementing `/wiki-lint` stale/orphan checks in Domain B
- Interleaving council sessions with domain audits
- Passing full conversation history to council subagents (pass only findings tables)
- Writing partial artifacts mid-session (write both files only when all councils complete)
- Skipping the Preparation phase (baseline numbers are required for the Executive Summary)

---

## Related Skills

| Skill | When to invoke |
|---|---|
| `/wiki-lint` | Run at the start of Domain B; capture its full output |
| `/nixos-patterns` | Reference during Domain D for dendritic pattern definition |
| `/verification-loop` | Use when executing changes from `audit-plan.md` in a future session |
| `/wiki-update <file>` | Use for Domain B wiki gap implementations (never edit wiki pages manually) |
| `/strategic-compact` | Invoke if context grows heavy mid-session (after Domain C is a natural checkpoint) |
| `/everything-claude-code:council` | Invoked once per domain during the Council Phase |
