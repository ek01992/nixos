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

## [2026-05-01] ingest | Retire ARCHITECTURE.md and LLM-WIKI.md
- Updated: [[concepts/dendritic-pattern]], [[concepts/flake-parts]], [[concepts/wrapper-modules]], [[features/niri]], [[features/noctalia]], [[overview]]
- Key changes: Removed ARCHITECTURE.md from sources: frontmatter on 6 pages; updated wiki-schema.md example; updated CLAUDE.md to point to wiki instead of ARCHITECTURE.md; added deprecation markers to ARCHITECTURE.md and LLM-WIKI.md
