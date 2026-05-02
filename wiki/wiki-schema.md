Use # Wiki Schema

Operational rules for maintaining this wiki. Read this before any ingest, query, or lint operation.

## Page Conventions

Every wiki page begins with YAML frontmatter:

```yaml
---
title: Page Title
type: host | feature | concept | module | overview | comparison
updated: YYYY-MM-DD
sources:
  - path/to/source.nix
  - modules/features/niri.nix
---
```

Cross-references use Obsidian-style links: `[[page-name]]` (filename without extension, relative to wiki root). For pages in subdirectories: `[[features/niri]]`, `[[hosts/nixxy]]`.

## Ingest Workflow

When a source file changes or a new one is added:

1. Read the changed source file(s)
2. Identify which wiki pages are affected (check index.md)
3. Update each affected page — revise facts, add new info, note contradictions
4. Update the `updated` date in frontmatter of every touched page
5. Update `index.md` if new pages were created or summaries changed
6. Append an entry to `log.md`:
   ```
   ## [YYYY-MM-DD] ingest | <source file or description>
   - Updated: [[page1]], [[page2]]
   - Key changes: <one-line summary>
   ```

## Query Workflow

When answering a question about the system:

> **Lookup order**: Read wiki pages before source files. The wiki is pre-synthesized; reading it is cheaper than re-deriving the same facts from `.nix` sources. Only read a source file directly when the relevant wiki page is insufficient or its `updated` date suggests it may be stale.

1. Read `index.md` to find relevant pages
2. Read those pages in full
3. Synthesize an answer with inline citations (e.g., "see [[features/niri]]")
4. If the answer is non-trivial and reusable, file it as a new page under `wiki/comparisons/` or `wiki/analyses/`
5. Append a log entry:
   ```
   ## [YYYY-MM-DD] query | <question summary>
   - Read: [[page1]], [[page2]]
   - Filed: [[comparisons/new-page]] (if applicable)
   ```

## Lint Checks

Run periodically (`"Lint the wiki."`):

- **Orphan pages**: pages with no inbound `[[links]]` from other wiki pages
- **Stale claims**: facts in wiki pages that contradict current .nix source files
- **Missing cross-references**: concepts mentioned in a page that have their own wiki page but aren't linked
- **Unlinked concepts**: important terms used repeatedly without a concept page
- **Dead sources**: `sources:` frontmatter entries pointing to files that no longer exist
- **Missing pages**: source files that exist but have no wiki coverage

After a lint pass, append:
```
## [YYYY-MM-DD] lint | <scope>
- Orphans: <list or "none">
- Stale claims: <list or "none">
- Fixed: <list of changes made>
```

## Log Format

`log.md` is append-only. Each entry:
```
## [YYYY-MM-DD] <operation> | <description>
```
Operations: `bootstrap`, `ingest`, `query`, `lint`.

Parseable with: `grep "^## \[" wiki/log.md | tail -10`

## Directory Layout

```
wiki/
├── wiki-schema.md      ← this file
├── index.md            ← content catalog (read first on every query)
├── log.md              ← append-only event log
├── overview.md         ← full-system synthesis
├── hosts/              ← one page per machine
├── features/           ← feature modules (niri, noctalia, …)
├── concepts/           ← architectural concepts
├── modules/            ← shared NixOS modules
├── comparisons/        ← filed query answers comparing things
└── analyses/           ← filed query answers analyzing things
```
