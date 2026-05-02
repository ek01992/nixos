# Bash Script Standards

Standards for every bash script in this repo (`scripts/`). Apply when writing or modifying any `.sh` file.

## Required Header

```bash
#!/usr/bin/env bash
set -euo pipefail
```

`set -euo pipefail` is mandatory — exit on error, undefined vars, and pipe failures.

## Required Structure

1. Shebang + `set -euo pipefail`
2. Module-level constants (UPPERCASE)
3. `usage()` function — prints to stderr, exits 1
4. Input validation (before touching any files)
5. Work (template generation, file writes, etc.)
6. `git add` newly created files
7. Structured output: files created, then "Next steps:"

## Variable Naming

- Module-level (script scope): `UPPERCASE`
- Function-local: declare with `local varname`

## Heredoc Quoting in Scripts That Generate Nix Code

Nix uses `${...}` for interpolation, which conflicts with bash variable expansion.

- Use `<<'EOF'` (quoted delimiter) for all Nix template blocks — prevents bash from expanding `${}` inside the Nix code
- Use `<<EOF` (unquoted) only when you need bash to substitute variables inside the block

For Nix templates with variable substitutions: write the template with `@PLACEHOLDER@` tokens, then apply `sed` after writing:

```bash
cat > "$OUTPUT_FILE" <<'EOF'
{ self, inputs, ... }:
{
  flake.nixosModules.@NAME@ = { pkgs, ... }: { };
}
EOF
sed -i "s/@NAME@/$NAME/g" "$OUTPUT_FILE"
```

## Input Validation

- Validate all required args before writing any files
- Check target path does not already exist before writing (fail fast, no clobber):
  ```bash
  [[ -e "$TARGET" ]] && { echo "error: $TARGET already exists" >&2; exit 1; }
  ```
- Print errors to stderr: `echo "error: ..." >&2`

## Post-Write

- `git add` all created files/directories at end of script — agents and users do not need to remember this
- Print a summary in this format:
  ```
  Created:
    path/to/file1.nix
    path/to/file2.nix

  Files staged with git add.

  Next steps:
    1. Edit file1.nix — replace TODO markers
    2. nix flake check
    3. nixos-rebuild build --flake .#<hostname>
  ```

## Script Location

All scripts live in `scripts/` at the repo root and must be executable (`chmod +x`).

After generating Nix files, agents should run `nixfmt-tree` to normalize formatting before committing.
