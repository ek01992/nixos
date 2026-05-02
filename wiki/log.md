# Wiki Log

Append-only record of wiki operations.  
Parse with: `grep "^## \[" wiki/log.md | tail -10`

---

## [2026-05-01] bootstrap | Initial wiki seeded from CLAUDE.md, ARCHITECTURE.md, and module sources

- Created: [[overview]], [[wiki-schema]]
- Created hosts: [[hosts/nixos-wsl]], [[hosts/nixxy]]
- Created features: [[features/niri]], [[features/noctalia]]
- Created concepts: [[concepts/dendritic-pattern]], [[concepts/flake-parts]], [[concepts/import-tree]], [[concepts/wrapper-modules]]
- Created modules: [[modules/common]]
- Created: [[index]]
- Sources read: flake.nix, modules/common.nix, modules/hosts/wsl/*, modules/hosts/nixxy/*, modules/features/niri.nix, modules/features/noctalia/noctalia.nix, modules/features/noctalia/noctalia.json, CLAUDE.md, ARCHITECTURE.md

## [2026-05-01] lint | full pass
- Orphans: none
- Stale: none
- Fixed: added modules/parts.nix to sources in [[concepts/flake-parts]]; corrected stale systems example (aarch64-linux was not present)
- No coverage: modules/parts.nix (resolved — added to [[concepts/flake-parts]])

## [2026-05-01] ingest | scaffolding system (CLAUDE.md, scripts/, .claude/skills/nixos-scaffold/)
- Created: [[concepts/scaffolding]]
- Updated: [[overview]] (added Scaffolding section, fixed aarch64-linux stale claim in module graph)
- Updated: [[index]] (added scaffolding concept row)
- Key changes: new scaffolding system with three bash scripts (new-host, new-feature, new-devshell) and /nixos-scaffold skill

## [2026-05-01] lint | full pass
- Orphans: none
- Stale: none (all sources 2026-05-01, all pages updated: 2026-05-01)
- Fixed: none
- No coverage: none (modules/devshells/default.nix now covered by [[modules/devshells]])

## [2026-05-01] ingest | modules/devshells/default.nix
- Created: [[modules/devshells]]
- Updated: [[overview]] (added claude-code-nix input, devshells entry in module graph, nix develop command, updated sources frontmatter)
- Updated: [[index]] (added devshells row under Modules)
- Key changes: new default devshell exposing devShells.default — Claude Code CLI (claude-code-nix input), dev tools (treefmt, nixfmt-tree, nil, ripgrep, fd, jq, neovim, gh), ANTHROPIC_API_KEY guard in shellHook

## [2026-05-01] ingest | Retire ARCHITECTURE.md and LLM-WIKI.md
- Updated: [[concepts/dendritic-pattern]], [[concepts/flake-parts]], [[concepts/wrapper-modules]], [[features/niri]], [[features/noctalia]], [[overview]]
- Key changes: Removed ARCHITECTURE.md from sources: frontmatter on 6 pages; updated wiki-schema.md example; updated CLAUDE.md to point to wiki instead of ARCHITECTURE.md; added deprecation markers to ARCHITECTURE.md and LLM-WIKI.md

## [2026-05-02] ingest | modules/hosts/nixxy/configuration.nix, modules/hosts/wsl/configuration.nix
- Updated: [[hosts/nixxy]], [[hosts/nixos-wsl]]
- Key changes: added home/shell/editor to imports list on both hosts; nixxy also updated with nerd-fonts packages, bluetooth section, and user packages table (waylock, grim, slurp, wl-clipboard, cliphist)

## [2026-05-02] ingest | modules/features/editor.nix, modules/features/home.nix, modules/features/shell.nix
- Created: [[features/editor]], [[features/home]], [[features/shell]]
- Updated: [[overview]] (added home-manager to inputs table; added editor/home/shell to module graph; updated sources frontmatter)
- Key changes: three new feature pages covering home-manager bridge (home), fish+starship (shell), and helix editor (editor); overview module graph now complete

## [2026-05-02] ingest | modules/features/niri.nix
- Updated: [[features/niri]]
- Key changes: expanded keybinds section from 3 to full set — apps (3), navigation (6), resize (2), window state (2), system (2), workspaces (Mod+1–9, Mod+Shift+1–9 via lib.range)

## [2026-05-02] lint | full pass (nixos-audit Domain B)
- Orphans: none
- Stale: [[hosts/nixxy]] (missing home/shell/editor imports); [[hosts/nixos-wsl]] (same); [[overview]] (missing editor/home/shell in module graph, missing home-manager input); [[features/niri]] (keybinds section documents 3 of ~20 binds)
- Fixed: none (audit is read-only; fixes scheduled in .claude/audit/audit-plan.md)
- No coverage: modules/features/editor.nix, modules/features/home.nix, modules/features/shell.nix
