# Exploration Efficiency

Rules for minimizing token waste on codebase exploration.

## Never Use Explore Agents for Known Paths

Explore agents return **summaries**, not full content. For any file whose path is already known (listed in CLAUDE.md, wiki/index.md, or mentioned in conversation), use the `Read` tool directly.

**Wrong:** spawn Explore agent to "read the wiki files"
**Right:** parallel `Read` calls on the specific paths

## Parallel Read Beats Sequential Explore

For 2–6 known files, send a single message with multiple `Read` tool calls. This:
- Returns exact content, not summaries
- Costs a fraction of one Explore agent invocation
- Eliminates the second-pass re-read that summaries force

## When Explore Agents Are Appropriate

Only when file paths are genuinely unknown and discovery is needed:
- "Find all files that reference X" (pattern not in CLAUDE.md)
- "What uses this module?" (reverse-lookup across the tree)
- Broad codebase surveys with uncertain scope

If CLAUDE.md or wiki/index.md already names the file, skip the agent.

## For Update Tasks: Git Diff First

Before reading any wiki page or source file for an update task, run:

```bash
git log --oneline -5 -- modules/
# or
git diff --stat HEAD~1
```

This immediately identifies which source files changed, so you read only the wiki pages whose `sources:` frontmatter lists those files — not the full index.

## Batch Operations

- Read multiple files in one message (parallel tool calls)
- Run independent bash commands in one message (parallel tool calls)
- Do not read `wiki/index.md` just to discover page paths you could derive from the changed file's location (e.g., `modules/features/niri.nix` → `wiki/features/niri.md`)
