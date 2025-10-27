# Rubric

## Table

| Category | Weight | 5 (Exemplary) | 4 (Strong) | 3 (Adequate) | 2 (Needs Work) | 1 (Poor) | 0 (Critical) |
|----------|--------|---------------|------------|--------------|----------------|----------|--------------|
| **Architecture** | 20% | Flake-based, clear hierarchy, zero duplication | Flake-based, logical grouping, minimal duplication | Basic structure OR flakes (not both) | Monolithic files, unclear boundaries | Single massive file | Non-functional |
| **Code Quality** | 15% | Pure functions, proper conditionals, all types defined | Mostly pure, good patterns, most types | Basic patterns, some typing | Imperative mix, missing types | No types, complex `with` abuse | Broken syntax |
| **Documentation** | 15% | Comprehensive README, module docs, CHANGELOG | Good README, most modules documented | Basic README, some comments | Minimal README, sparse comments | README stub only | None |
| **Maintainability** | 20% | <2hr onboard, consistent patterns, verification steps | 6-month recall possible, mostly consistent | Logical but requires investigation | Significant reverse-engineering needed | Only author understands | Unmaintainable |
| **Security** | 15% | No secrets, secrets mgmt, SSH hardened, automated updates | No secrets, key-only SSH, firewall enabled | No obvious secrets, SSH secured, firewall on | Unclear secrets, password SSH, no firewall | Possible secrets, weak config | Secrets committed |
| **Testing** | 10% | Automated validation, VM testing, dry-run required | Manual checklist, build testing standard | Basic dry-build usage, can roll back | YOLO deploys | No testing | No way to test |
| **Version Control** | 5% | Conventional commits, atomic changes, signed | Good messages, logical branching | Readable history, feature branches | Vague messages, direct to main | “WIP” commits | Not tracked |

## At-a-Glance Grading

**Calculate Your Score:**

```math
Total = (Architecture × 0.20) + (Code Quality × 0.15) + (Documentation × 0.15) +
        (Maintainability × 0.20) + (Security × 0.15) + (Testing × 0.10) +
        (Version Control × 0.05)
```

**Overall Grades:**

- **4.5-5.0** → Production-ready, exemplary
- **4.0-4.4** → Strong, minor improvements only
- **3.5-3.9** → Good baseline, some refactoring beneficial
- **3.0-3.4** → Adequate, needs attention
- **2.5-2.9** → Functional but requires significant work
- **2.0-2.4** → Major refactoring needed
- **<2.0** → Critical issues, consider restart

---

## Rapid Assessment Checklist

### Architecture (20%)

- [ ] Using flakes with `flake.lock`?
- [ ] Modules organized by category?
- [ ] Helper functions for consistency?
- [ ] Host configs separated from reusable modules?
- [ ] No code duplication?

**Quick Win:** Add `mkSystem` helper if missing, organize into `modules/` directory

### Code Quality (15%)

- [ ] Using `lib.mkIf` for conditionals?
- [ ] All options have types (`mkOption` with `type = types.*`)?
- [ ] `mkEnableOption` for boolean toggles?
- [ ] Minimal `with` statements?
- [ ] Pure functions (no `nixos-rebuild` calls in configs)?

**Quick Win:** Add types to all `mkOption` declarations

### Documentation (15%)

- [ ] README with setup instructions?
- [ ] Module headers with verification commands?
- [ ] Inline comments explain *why* not *what*?
- [ ] All options have descriptions?
- [ ] CHANGELOG for breaking changes?

**Quick Win:** Add verification commands as comments in module headers

### Maintainability (20%)

- [ ] Patterns consistent across codebase?
- [ ] Could someone else modify this in 30 min?
- [ ] Rollback process documented?
- [ ] Each module has test/verify steps?
- [ ] Secrets management clear?

**Quick Win:** Document verification commands for each service

### Security (15%)

- [ ] Git history clean of secrets?
- [ ] SSH key-only authentication?
- [ ] Firewall configured (or documented, why not)?
- [ ] Services run as non-root where possible?
- [ ] Update strategy exists?

**Quick Win:** Audit git history: `git log -S "password" -S "api_key" -S "token"`

### Testing (10%)

- [ ] `nix flake check` passes?
- [ ] Can build without applying (`nixos-rebuild dry-build`)?
- [ ] Tested rollback at least once?
- [ ] VM testing workflow documented?

**Quick Win:** Add `just check` and `just test` commands

### Version Control (5%)

- [ ] `.gitignore` excludes `result`, build artifacts?
- [ ] `flake.lock` committed?
- [ ] Commit messages descriptive?
- [ ] Feature branches used?

**Quick Win:** Add `.gitignore` with NixOS artifacts

---

## Priority Fix Matrix

**When score < 3.0:**

| Category | Priority | Timeline | Impact |
|----------|----------|----------|---------|
| Security | 🔴 CRITICAL | Immediate | Production risk |
| Maintainability | 🟠 HIGH | 1 sprint | Bus factor risk |
| Architecture | 🟡 MEDIUM | Incremental | Technical debt |
| Documentation | 🟡 MEDIUM | As you fix | Knowledge risk |
| Code Quality | 🟢 LOW | Gradual | Code smell |
| Testing | 🟢 LOW | Gradual | Stability risk |
| Version Control | 🟢 LOW | Gradual | Collaboration |

---

### Red Flags by Category

**Architecture:**

- ⚠️ All config in one file
- ⚠️ No flakes
- ⚠️ Duplicate code across hosts

**Code Quality:**

- ⚠️ No types on options
- ⚠️ Nested `with` statements
- ⚠️ Imperative commands in configs.

**Documentation:**

- ⚠️ No README
- ⚠️ No option descriptions
- ⚠️ Complex logic without comments

**Maintainability:**

- ⚠️ Only you understand it
- ⚠️ No verification commands
- ⚠️ Pattern inconsistencies

**Security:**

- 🚨 Secrets in git history
- 🚨 Password SSH enabled
- 🚨 No firewall without justification
- ⚠️ No update strategy

**Testing:**

- ⚠️ Never tested rollback
- ⚠️ Deploy directly to production
- ⚠️ No dry-run workflow

**Version Control:**

- ⚠️ Not in git
- ⚠️ `flake.lock` gitignored
- ⚠️ Meaningless commit messages
