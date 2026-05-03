# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A NixOS flake configuration for two hosts (`nixos-wsl` and `nixxy`), built with `flake-parts` and `import-tree`. Every `.nix` file under `modules/` is automatically loaded as a flake-parts module — no explicit import list to maintain.

## ECC Overrides (NixOS-specific)

This is a NixOS flake config repo, not a software project. The following global ECC behaviors do **not** apply here:

- **No code-reviewer, security-reviewer, or tdd-guide agents** for `.nix` file edits — they add cost without actionable output on config files. Config correctness is validated by `nix flake check` and `nixos-rebuild build`.
- **No 80% test coverage or TDD requirements** — NixOS configs don't have unit tests. Use `nix flake check` + build validation instead.
- **No development-workflow research phase** (gh search, library docs, package registries) for Nix module changes — the `nixos` MCP tool is the correct lookup path.
- **Wiki-first lookups**: For any question about host configs, module structure, feature details, or architecture — read `wiki/index.md` first and navigate to the relevant page. Read source files directly only when the wiki page is insufficient or marked stale.

## Common Commands

```bash
# Validate the flake (check for evaluation errors)
nix flake check

# Build a host configuration (without switching)
nixos-rebuild build --flake .#nixos-wsl
nixos-rebuild build --flake .#nixxy

# Apply configuration to the running system
sudo nixos-rebuild switch --flake .#nixos-wsl   # on WSL
sudo nixos-rebuild switch --flake .#nixxy        # on nixxy

# Build a specific package
nix build .#packages.x86_64-linux.myNiri
nix build .#packages.x86_64-linux.myNoctalia

# Enter the dev shell (Claude Code CLI + Nix dev tools)
nix develop

# Format all Nix files
nixfmt-tree

# Shell aliases (defined in modules/common.nix, available on both hosts)
# nrb  → nixos-rebuild build --flake $HOME/nixos
# nrs  → sudo nixos-rebuild switch --flake $HOME/nixos
# nfc  → nix flake check
# nfu  → nix flake update

# Evaluate a specific config option interactively
nix repl
# then inside repl: :lf .

# Debug a specific option value
nix eval .#nixosConfigurations.nixxy.config.<option>
```

## Scaffolding

Generate boilerplate for new components — templates match exact repo conventions:

```bash
# New host (creates modules/hosts/<hostname>/{default,configuration,hardware}.nix)
./scripts/new-host.sh <hostname> [bare-metal|wsl]

# New feature module
./scripts/new-feature.sh <name> [--nixos-module-only|--package-only|--both|--wrapped <wrapper>]

# New devShell (creates modules/devshells/<name>.nix)
./scripts/new-devshell.sh <name>
```

Scripts `git add` new files automatically and print exact next steps. Use `/nixos-scaffold` for guided usage.

## Architecture

Full reference: [[overview]] in wiki. Quick map:
- `flake.nix` → delegates to flake-parts + import-tree (no manual imports needed)
- `modules/parts.nix` → declares supported systems (`x86_64-linux`)
- Hosts: [[hosts/nixos-wsl]] (WSL2, dir: `wsl/`), [[hosts/nixxy]] (bare-metal + niri, dir: `nixxy/`)
- Features: `modules/features/` → [[features/niri]], [[features/noctalia]]
- Shared: `modules/common.nix` (baseline for all hosts)
- Noctalia config: edit `modules/features/noctalia/noctalia.json` directly (the `.nix` reads it at build time)
- Pure eval gotcha: `git add <file>` before `nix flake check` for any new `.nix` file
- Cross-ref in `perSystem`: `self'.packages.X`; in `flake.*`: `self.packages.${pkgs.stdenv.hostPlatform.system}.X`

## Claude Code Guidance

### Skills Quick Reference

| Situation | Skill |
|-----------|-------|
| Any structural/pattern question about this repo | `/nixos-patterns` (run first) |
| Scaffold new host, feature, or devShell | `/nixos-scaffold` |
| Source file changed — update wiki | `/wiki-update <file>` |
| Periodic wiki hygiene | `/wiki-lint` |
| Before ANY commit | `/verification-loop` |
| Update flake inputs | `/nix-update` |
| Long session nearing context limit | `/strategic-compact` |
| Comprehensive config audit (tokens, wiki, automation, modules, scripts) | `/nixos-audit` |

### Lookups

- **Package/option lookups**: Use the `nixos` MCP server — faster and more current than `nix search` or manual nixpkgs browsing. See `.claude/rules/wiki-lookup.md` for the full retrieval hierarchy.
- **Wiki**: Read `wiki/index.md` first on any codebase question, then navigate to the relevant page. See `wiki/wiki-schema.md` for ingest/query/lint rules.
- **Architecture concepts**: See [[concepts/dendritic-pattern]], [[concepts/flake-parts]], and [[concepts/wrapper-modules]] in the wiki.

### Efficiency Rules

- **Git-diff first for update tasks**: Before reading any wiki page or source file for a doc-sync task, run `git log --oneline -5 -- modules/` or `git diff --stat HEAD~1` to identify exactly which files changed. Read only the wiki pages whose `sources:` frontmatter lists those files.
- **Parallel Read over Explore agents**: For any file whose path is known, use parallel `Read` calls — not an Explore agent. Explore returns summaries; `Read` returns exact content. See `.claude/rules/exploration-efficiency.md`.
- **`nixfmt-tree` availability**: If `nixfmt-tree` is not on PATH, use `nix run nixpkgs#nixfmt-tree` or `nix fmt` (both are in the allow list).
