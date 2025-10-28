# NixOS Flake Architecture: Grading Rubric

**Purpose**: Objective evaluation of NixOS flake configurations against documented standards.  
**Scoring**: 100 points total. ≥90 = Excellent, 80-89 = Good, 70-79 = Needs Improvement, <70 = Major Issues

## Scoring Matrix

| Category | Points | Excellent (Full Points) | Partial Credit | Fail (0 Points) | Verification Method |
|----------|--------|-------------------------|----------------|-----------------|---------------------|
| **Directory Structure** | 15 | Standard 3-tier structure: `hosts/{common/{core,optional},<hostname>}/`, `modules/`, `secrets/`, `lib/` present and correct | Missing 1-2 optional dirs (`lib/` or organized `secrets/`) but core structure intact | Core structure violated: missing `hosts/common/core/` or host dirs mixed with shared | `find . -type d -maxdepth 2` |
| **flake.lock in Git** | 5 | `flake.lock` committed, not in `.gitignore`, update commits explain changes | `flake.lock` committed but updates lack context | `flake.lock` in `.gitignore` or not tracked | `git ls-files flake.lock && grep -q flake.lock .gitignore` |
| **Host Isolation** | 15 | Zero host-specific values (IPs, hostnames, paths) in `modules/` or `lib/`; all in `hosts/<hostname>/` | 1-2 minor violations (e.g., default port that could be parameterized) | Multiple host-specific values hardcoded in shared modules | `rg '\b(10\.\d+\.\d+\.\d+|192\.168)\b' modules/ lib/` |
| **Module Depth** | 10 | All modules ≤2 import levels from host `default.nix` | One module exceeds depth by 1 level (depth=3) | Multiple modules >3 levels deep | Manual import chain tracing from `hosts/*/default.nix` |
| **Anti-Pattern Avoidance** | 15 | No violations: magic derivations have comments, no config mixing, no premature lib functions (<3 uses) | 1-2 minor violations (missing comment, single-use helper with clear intent) | Multiple violations: specialArgs abuse, mixing configs, deep nesting | See checklist below |
| **Abstraction Timing** | 10 | Scaling pattern matches host count: 1-2 explicit, 3-5 uses mkHost, 5+ metadata-driven | Pattern one level off (e.g., mkHost at 2 hosts, metadata at 4 hosts) | Significant mismatch: no abstraction at 6+ hosts or complex generators at 1-2 hosts | Count `nixosConfigurations` entries, analyze pattern |
| **Secrets Management** | 15 | sops-nix integrated, `.sops.yaml` present, all secrets encrypted, no plaintext credentials | sops-nix present but incomplete coverage (some secrets in plaintext files) | No secrets management or plaintext credentials in repo | `rg -i 'password.*=.*"[^$]' --type nix && file secrets/**/*.yaml` |
| **Verification Workflow** | 10 | CI/CD runs `nix flake check`, documented test workflow, NixOS tests for critical services | Manual verification workflow documented but not automated | No verification process, direct production deploys | Check `.github/workflows/` or docs, review `checks` in flake |
| **Code Quality** | 10 | Complex derivations have `# Why:` comments, module purposes clear, consistent formatting | Missing 10-20% of expected comments but intent discernible | Sparse/no comments, unclear module purposes, inconsistent style | Count comment-to-code ratio in complex functions |
| **Git Practices** | 5 | All config files tracked, meaningful commit messages, atomic changes | Minor issues: some "WIP" commits or large unfocused changes | Missing files, no `.gitignore`, unclear commit history | `git log --oneline -20` |

**Total: 100 points**

---

## Anti-Pattern Checklist (for 15-point category)

Check these specific violations:

| Anti-Pattern | Detection Method | Points Deducted |
|--------------|------------------|-----------------|
| Magic derivations without comments | Search for `mkDerivation`, `buildGoModule`, custom lib functions >10 lines without preceding comment | -5 per occurrence |
| specialArgs with >3 entries | Count keys in `specialArgs = { ... }` | -3 if >3 keys |
| Config mixing | Find host-specific values in `modules/` or `lib/` | -5 per occurrence |
| Single-use lib functions | `rg '<function-name>' --type nix \| wc -l` must be ≥3 for each lib function | -3 per function |
| Deep nesting | Import depth >2 from host config | -4 if any module exceeds limit |

---

## Scoring Interpretation

### 90-100: Production Ready
- Follows all documented patterns
- Scales appropriately for current size
- Maintainable by new team members
- Bus factor risk minimized

### 80-89: Good with Minor Issues
- Core patterns followed
- 1-3 minor violations that don't impact maintainability
- Likely scalable with minor refactoring

### 70-79: Needs Refactoring
- Several pattern violations
- Technical debt building
- Will cause pain when scaling
- Address issues before adding hosts

### <70: Major Rework Required
- Fundamental pattern violations
- High bus factor risk
- Likely broken abstractions
- Refactor before continued development

---

## Quick Pass/Fail Checks

**Instant Fail Conditions** (override score to 0):
- Plaintext secrets committed to repo
- No `flake.nix` in root
- Shared modules import from specific `hosts/<hostname>/` dirs

**Instant Pass to 80+** (if all true):
- Directory structure matches standard exactly
- All 10 anti-pattern checks pass
- sops-nix properly configured
- flake.lock tracked in git
- Host count matches abstraction pattern

---

## Automated Scoring Script

```bash
#!/usr/bin/env bash
# Score NixOS flake configuration automatically

score=0

# Directory structure (15 pts)
[[ -d hosts/common/core ]] && score=$((score + 5))
[[ -d hosts/common/optional ]] && score=$((score + 5))
[[ -d modules ]] && score=$((score + 3))
[[ -d secrets ]] && score=$((score + 2))

# flake.lock (5 pts)
git ls-files | grep -q flake.lock && score=$((score + 5))

# Host isolation (15 pts - check for IP patterns in modules)
ip_count=$(rg '\b(10\.\d+\.\d+\.\d+|192\.168)\b' modules/ lib/ 2>/dev/null | wc -l)
[[ $ip_count -eq 0 ]] && score=$((score + 15)) || score=$((score + 5))

# Secrets (15 pts)
if [[ -f .sops.yaml ]]; then
  score=$((score + 10))
  plaintext=$(rg -i 'password.*=.*"[^$]' --type nix 2>/dev/null | wc -l)
  [[ $plaintext -eq 0 ]] && score=$((score + 5))
fi

# Verification (10 pts)
nix flake check --no-build &>/dev/null && score=$((score + 10))

echo "Automated Score: $score/60 (remaining 40 pts require manual review)"
```

---

## Usage Notes

**For Solo Maintainers**:
- Self-assess monthly
- Track score trends over time
- Perfect score (100) is achievable and encouraged
- Focus first on categories with 0 points

**For AI Agents/Reviews**:
- All checks are objective and scriptable
- No subjective "code smell" categories
- Clear thresholds for partial credit
- Reference report line numbers in findings

**For Team Onboarding**:
- New members should review rubric first
- Score existing config together as training
- Use rubric to guide first contributions
- Aim for maintaining/improving score with each PR
