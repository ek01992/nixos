# Wiki & Data Retrieval Order

## Lookup Hierarchy (Questions)

For any **question** about this repo's configuration, hosts, features, modules, or architecture:

1. **Wiki first** — read `wiki/index.md`, then navigate to the relevant page
2. **Source files second** — only if the wiki page is insufficient or its `updated:` date is older than the source file's last git commit
3. **nixos MCP tool** — for package/option lookups, channel info, or anything about nixpkgs
4. **Never**: general web search or training-data guesses for Nix package attributes

## Update Task Hierarchy (Post-Change Doc Sync)

For **update tasks** (syncing docs after code changes) — use this order instead:

1. **Git diff first** — identify what changed:
   ```bash
   git log --oneline -5 -- modules/
   # or
   git diff --stat HEAD~1
   ```
2. **Map to wiki pages** — derive the wiki path directly from the source path (e.g., `modules/features/niri.nix` → `wiki/features/niri.md`); do not read `wiki/index.md` first when the mapping is obvious
3. **Read only the affected pages** — parallel `Read` calls on the specific files
4. **Use `/wiki-update <file>`** — never edit wiki pages manually (see below)

## Wiki Updates: Use the Skill

**`/wiki-update <file>` is mandatory for all wiki page edits.** Manual edits bypass `wiki/log.md` and may miss `wiki/index.md` summary updates.

```
/wiki-update modules/features/niri.nix
/wiki-update modules/hosts/nixxy/configuration.nix modules/features/niri.nix
```

The skill handles: page edits, index.md summary refresh, and log.md append in one pass.

## Staleness Check

Before trusting a wiki page for a question, verify it isn't stale:

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

## Nixpkgs Module Source

For questions about what a NixOS option *actually does* (e.g., what `programs.niri.enable` sets up), check the nixpkgs module source in the store before making MCP lookups:

```bash
find /nix/store -name "<module>.nix" -path "*/nixos/modules/*" 2>/dev/null | head -3
```

This avoids a round-trip MCP call when the module is already on disk.

## Additional Notes

- For flake-parts or wrapper-modules API questions, check the nixpkgs module source on-disk first (`find /nix/store -name "*.nix" -path "*/nixos/modules/*"`) before making MCP calls
- For any file whose path is known, use parallel `Read` calls — do not spawn Explore agents
