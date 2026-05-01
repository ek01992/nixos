# Testing Requirements

## NixOS Configuration Testing

For NixOS flake configurations, testing means:
1. **Build validation** — `nixos-rebuild build` or `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`
2. **Evaluation** — `nix eval .#nixosConfigurations.<host>.config.system.build.toplevel`
3. **nixos-test modules** — for complex service configurations, write NixOS test modules using `nixosTest`
4. **Lint/format** — `nixpkgs-fmt` or `alejandra` for formatting; `nix flake check` for structural validity

## Verification Before Commits

Before committing NixOS config changes:
1. Run `nix flake check` to validate flake outputs
2. Run `nixos-rebuild build --flake .#nixos-wsl` and `nixos-rebuild build --flake .#nixxy`
3. Run `nixfmt-tree` to format all .nix files
4. For destructive changes, test in a VM first (`nixos-rebuild build-vm`)

## Test-Driven Approach for NixOS

When adding new modules or options:
1. Define the expected behavior (what the resulting system should do)
2. Write a `nixosTest` if the change warrants it
3. Build and verify the configuration evaluates correctly
4. Apply and confirm on target system

## Troubleshooting Build Failures

1. Check `nix log` for build errors
2. Use `nix repl` to interactively evaluate expressions
3. Isolate with `nix eval .#nixosConfigurations.<host>.config.<option>`
4. Use **build-error-resolver** agent for complex errors
