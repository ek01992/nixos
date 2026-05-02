---
name: wiki-update
description: Ingest a changed source file into the wiki — update affected pages, index.md, and log.md
version: 1.0.0
source: project-local
---

# Wiki Update

Ingests a changed or new source file into the wiki. Updates affected pages, index.md, and appends a log entry.

## Trigger Phrases

- `/wiki-update <file>`
- `"Update the wiki — I just changed <file>."`
- `"Update the wiki — I just added <file>."`
- `"Ingest <file> into the wiki."`

## Arguments

- **`<file>`** (required): Path to the changed or new source file (e.g., `modules/features/niri.nix`, `modules/hosts/nixxy/configuration.nix`)
- **`[description]`** (optional): What changed — e.g., "added swipe gestures", "new host". If omitted, derive from a diff or file read.

## Workflow

### 1. Read the changed file

Read `<file>` in full. If a description was provided, use it as context. If not, read the file carefully to understand what changed relative to what the wiki currently says.

### 2. Identify affected wiki pages

Read `wiki/index.md` to see the full page catalog. Then check two sources:

- **Direct match**: any wiki page whose `sources:` frontmatter lists `<file>`
- **Indirect match**: any wiki page whose content references this file's entities (host name, feature name, module export)

Read each candidate page.

### 3. Determine update type

| Situation | Action |
|-----------|--------|
| Source file already has a wiki page | Update existing page |
| Source file is new with no wiki page | Create a new wiki page |
| Source file was deleted | Remove its path from `sources:` on all pages; flag if the page becomes sourceless |
| Source file affects multiple pages | Update all affected pages |

### 4. Update existing pages

For each affected wiki page:

- Revise facts to match the current state of the source file
- Add new information introduced by the change
- Remove or strike claims that are no longer true
- Update `updated: YYYY-MM-DD` in frontmatter to today
- Keep `sources:` accurate — add `<file>` if it's newly relevant, remove if no longer

Do not rewrite pages from scratch — make targeted edits that reflect the delta.

### 5. Create a new page (if needed)

If the source file has no wiki page, create one at the appropriate path:

| Source location | Wiki page |
|----------------|-----------|
| `modules/hosts/<dir>/` | `wiki/hosts/<hostname>.md` |
| `modules/features/<name>.nix` | `wiki/features/<name>.md` |
| `modules/<name>.nix` | `wiki/modules/<name>.md` |
| Other | `wiki/concepts/<name>.md` |

Use this frontmatter template:

```yaml
---
title: <Descriptive Title>
type: host | feature | concept | module
updated: YYYY-MM-DD
sources:
  - <file>
---
```

Seed content from the source file — don't invent. Cover: what it exports, what it configures, what it depends on, and which wiki pages cross-reference it.

### 6. Update wiki/index.md

If any page summaries changed or a new page was created:

- Update the one-line summary for changed pages
- Add a new row for any new page (in the correct table section)
- Update the `Last updated:` date at the top

### 7. Append log entry

```markdown
## [YYYY-MM-DD] ingest | <file>
- Updated: [[page1]], [[page2]]
- Created: [[new-page]] (if applicable)
- Key changes: <one-line summary of what changed>
```

## Multiple Files

If the user says "I changed X and Y" or multiple files are implicated, run the workflow for each file in sequence. Batch the log entry.

## Notes

- Never modify source `.nix` files — only wiki pages, `index.md`, and `log.md`
- Prefer targeted edits over full page rewrites — the diff should be proportional to the change
- If the change is large enough to affect `overview.md`, update it last (it synthesizes everything else)
- When in doubt about what changed, read the git diff: `git diff HEAD -- <file>`
