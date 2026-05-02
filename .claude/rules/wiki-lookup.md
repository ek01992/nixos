# Wiki & Data Retrieval Order

## Lookup Hierarchy

For any question about this repo's configuration, hosts, features, modules, or architecture:

1. **Wiki first** — read `wiki/index.md`, then navigate to the relevant page
2. **Source files second** — only if the wiki page is insufficient or its `updated:` date is older than the source file's last git commit
3. **nixos MCP tool** — for package/option lookups, channel info, or anything about nixpkgs
4. **Never**: general web search or training-data guesses for Nix package attributes

## Staleness Check

Before trusting a wiki page, verify it isn't stale:

```bash
git log -1 --format=%ci -- <source-file-path>
```

Compare that date to the page's `updated:` frontmatter. If the source commit is newer, read the source file directly and note the wiki page may need an update.

## Package and Option Lookups

Always use the `nixos` MCP tool (available via `mcp__nixos__nix`):

- Package info: `{"action":"info","query":"<name>","channel":"nixos-unstable"}`
- Option search: `{"action":"search","query":"<option>","type":"options"}`
- Home-manager: `{"action":"search","source":"home-manager","query":"<option>"}`

Never use `nix search nixpkgs <name>` in a shell call — the MCP is faster and more current.

## What Not to Do

- Do not read `.nix` source files to answer structural questions the wiki already covers
- Do not run `nix search` via Bash when the MCP is available
- Do not use `documentation-lookup` or `deep-research` skills — not configured for this project
