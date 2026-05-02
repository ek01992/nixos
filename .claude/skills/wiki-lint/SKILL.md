---
name: wiki-lint
description: Lint and validate the wiki — broken wikilinks, dead sources, orphan pages, missing coverage, stale dates
version: 1.0.0
source: project-local
---

# Wiki Lint

Validates the wiki at `wiki/` against the live source files and internal link graph.

## Trigger Phrases

- `/wiki-lint`
- `"Lint the wiki."`
- `"Run a wiki lint pass."`

## Workflow

### 1. Load the catalog

Read `wiki/index.md` to build the expected page list. Read `wiki/wiki-schema.md` to confirm current lint rules.

### 2. Discover all wiki pages

```bash
find wiki -name "*.md" ! -name "index.md" ! -name "wiki-schema.md" ! -name "log.md"
```

Read every discovered page. Parse frontmatter (`title`, `type`, `updated`, `sources`) and body.

### 3. Run each check

#### Broken wikilinks

Grep all wiki pages for `[[...]]` patterns:

```bash
grep -roh '\[\[[^\]]*\]\]' wiki/
```

For each `[[page-name]]`, resolve to `wiki/<page-name>.md` (handle subdirectory links like `[[features/niri]]` → `wiki/features/niri.md`). Flag any that don't resolve to an existing file.

#### Dead sources

For each page, read its `sources:` frontmatter list. For each entry, check the path exists:

```bash
ls <source-path>
```

**Auto-fix**: Remove dead entries from `sources:` and update frontmatter. If the page's entire `sources:` list is empty after cleanup, flag for human review.

#### Orphan pages

Build an inbound-link map: for every `[[page-name]]` found across all wiki pages, record which page links to it. Any wiki page with zero inbound links is an orphan. **Exception**: `overview.md` is always exempt (it's the synthesis root, linked from nowhere but read everywhere).

#### Missing frontmatter fields

For each page, confirm all required fields are present: `title`, `type`, `updated`, `sources`. 

**Auto-fix**: Add missing fields as skeleton values and flag them:
- `title`: derive from filename (title-case, replace hyphens with spaces)
- `type`: default to `concept` — **flag for human review**
- `updated`: today's date
- `sources`: empty list — **flag for human review**

#### Missing wiki coverage

List all `.nix` files under `modules/`:

```bash
find modules -name "*.nix"
```

For each file, check if any wiki page lists it in `sources:`. Files with no wiki coverage are flagged as candidates for new pages.

#### Stale page dates

For each wiki page, for each path in `sources:`, get the last git commit date of the source:

```bash
git log -1 --format=%ci -- <source-path>
```

If the source's last commit is **newer** than the page's `updated` date, flag: `"<source> changed after [[page]] was last updated"`.

### 4. Report

Print a categorized report:

```
## Wiki Lint Report — YYYY-MM-DD

### FIXED (auto-corrected)
- [dead source] removed path/to/gone.nix from sources in [[features/niri]]
- [frontmatter] added missing title to [[concepts/new-concept]]

### WARN (flag for review)
- [orphan] [[concepts/flake-parts]] has no inbound links
- [stale] modules/features/niri.nix changed 2026-04-15; [[features/niri]] last updated 2026-03-01
- [no coverage] modules/hosts/nixxy/hardware.nix has no wiki page

### PASS
- Wikilinks: all resolve
- Sources: all paths exist (after auto-fix)
- Frontmatter: complete on all pages
```

### 5. Append log entry

```markdown
## [YYYY-MM-DD] lint | full pass
- Orphans: [[page]] or "none"
- Stale: [[page]] (source newer) or "none"
- Fixed: removed dead source in [[page]]; added frontmatter to [[page]] (or "none")
- No coverage: modules/path/to/file.nix (or "none")
```

## Notes

- Never modify source `.nix` files — only wiki pages and `log.md`
- When auto-fixing frontmatter, always flag `type` as needing review if you guessed it
- Run lint before and after a large ingest to confirm consistency
