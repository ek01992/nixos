# NixOS Advanced Patterns & Reference

This document contains detailed patterns and examples extracted from cursor rules for human reference. For AI assistant guidelines, see [AGENTS.md](AGENTS.md).

## Performance & Optimization

### Build Output Monitoring

**Setup** (add to configuration.nix):
```nix
environment.systemPackages = [ pkgs.nix-output-monitor ];

# Alias in shell config
nix-rebuild = "nixos-rebuild switch --flake . 2>&1 | nom";
```

**Usage**:
```bash
# Any nix command
nix build .#package 2>&1 | nom
nix develop --command cargo build 2>&1 | nom
# Shows:
# - Build progress with timing
# - Dependency tree
# - Failed derivations clearly
# - Summary statistics
```

### Secret Management

**Option 1: agenix (simpler, age-based)**
```nix
# flake.nix
{
  inputs.agenix.url = "github:ryantm/agenix";

  outputs = { agenix, ... }: {
    nixosConfigurations.hostname = {
      modules = [
        agenix.nixosModules.default
        {
          age.secrets.mySecret = {
            file = ./secrets/mySecret.age;
            owner = "username";
            mode = "0400";
          };

          # Use: config.age.secrets.mySecret.path
        }
      ];
    };
  };
}
```

**Option 2: sops-nix (more features, complex)**
```nix
# flake.nix
{
  inputs.sops-nix.url = "github:Mic92/sops-nix";

  outputs = { sops-nix, ... }: {
    modules = [
      sops-nix.nixosModules.sops
      {
        sops = {
          defaultSopsFile = ./secrets.yaml;
          age.keyFile = "/persistent/etc/sops/age/keys.txt";
          secrets.database-password = {
            owner = "postgres";
          };
        };
      }
    ];
  };
}
```

**Choice**: agenix for solo admin (simpler), sops-nix for team (more features).

### Filesystem Performance

**Recommended for Nix workloads**:
```nix
# For desktop /nix/store
fileSystems."/nix" = {
  device = "/dev/disk/by-label/nix";
  fsType = "f2fs";
  options = [ "compress_algorithm=zstd" "compress_chksum" "atgc" ];
};
```

**Why f2fs**:
- Faster than btrfs for Nix build workloads
- Good compression (saves space)
- No need for btrfs snapshots (generations handle this)

**Alternative**: XFS for servers, ZFS if needing snapshots for other reasons.

### Debugging Workflow (Modern Commands)

```bash
# Syntax validation
nix-instantiate --parse file.nix
# Evaluate expression
nix eval .#nixosConfigurations.hostname.config.services.nginx
# Trace evaluation (add to code)
builtins.trace "value: ${value}" expression
# Build logs
nix log .#package
# or: nix log /nix/store/hash-package
# Derivation inspection
nix derivation show .#package
# Dependency analysis
nix why-depends /run/current-system /nix/store/hash-package
nix-store -q --tree /run/current-system
# Store optimization
nix store optimise  # Deduplicate (can save GB)
nix store gc        # Remove unused
nix store gc --print-dead  # Preview what would be removed
```

### Flake Templates

```bash
# See available templates
nix flake show templates
# Initialize from template
nix flake init -t github:NixOS/templates#full
# Custom template repository
nix flake init -t github:yourusername/templates#nixos-desktop
```

## Package Management

### Multiple Nixpkgs Versions

**Modern input-based approach**:
```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { nixpkgs, nixpkgs-stable, ... }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      specialArgs = {
        pkgs-stable = import nixpkgs-stable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      modules = [{
        # Use in config
        environment.systemPackages = [ pkgs-stable.package ];
      }];
    };
  };
}
```

**Alternative overlay pattern**:
```nix
nixpkgs.overlays = [
  (final: prev: {
    stable = import nixpkgs-stable {
      system = final.system;
      config = final.config;
    };
  })
];
# Use: pkgs.stable.package
```

### Search & Discovery Workflow

**Modern search commands**:
```bash
# Search packages (fast, cached)
nix search nixpkgs vim
# Search with regex
nix search nixpkgs 'firefox.*'
# Search options
nix search nixpkgs --option # (not widely supported yet)
# Use: https://search.nixos.org/options
# Show package details
nix eval nixpkgs#package.meta.description
```

### Package Information Commands

```bash
# Why is package in my system?
nix why-depends /run/current-system nixpkgs#package
# What depends on this?
nix-store -q --referrers /nix/store/hash-package
# Derivation details
nix derivation show nixpkgs#package
# Build without installing
nix build nixpkgs#package
ls result/
```

## Advanced Flakes

### Cherry-Pick Unmerged PRs

**Apply patches from open PRs before merge**:

```nix
# flake.nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      patches = [
        {
          url = "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/292148.diff";
          hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          # Put dummy hash, get real from error message
        }
      ];

      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      patchedNixpkgs = pkgs.applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        patches = map pkgs.fetchpatch patches;
      };
    in {
      nixosConfigurations.hostname =
        (import "${patchedNixpkgs}/nixos/lib/eval-config.nix") {
          inherit system;
          modules = [ ./configuration.nix ];
        };
    };
}
```

**Auto-detection**: When PR merges, patch fails → reminder to remove.

### Following Nixpkgs Main

**Use specific branches/commits**:

```nix
inputs = {
  # Specific commit
  nixpkgs.url = "github:NixOS/nixpkgs/abc123def456";

  # Specific PR (while testing)
  nixpkgs-pr.url = "github:user/nixpkgs/branch-name";

  # Local development
  nixpkgs.url = "path:/home/user/nixpkgs";
  # or: "git+file:///home/user/nixpkgs"
};
```

**Workflow**:
1. Fork/clone nixpkgs
2. Make changes
3. Point flake input to local path
4. Test: `nixos-rebuild build --flake .#hostname`
5. Submit PR when working

### Flake Development Tools

**Interactive Exploration**:
```bash
# Enter REPL with flake
nix repl
:lf .  # or :load-flake (shorter alias)
:lf github:NixOS/nixpkgs/nixos-unstable
# Tab completion available
outputs.nixosConfigurations.<TAB>
# Evaluate attributes
:p outputs.nixosConfigurations.hostname.config.services
```

**Build Monitoring**:
```bash
# Pretty build output
nix build --log-format internal-json 2>&1 | nom
# Works with nixos-rebuild
nixos-rebuild build --flake . 2>&1 | nom
# Install nom
nix shell nixpkgs#nix-output-monitor
# or add to config:
environment.systemPackages = [ pkgs.nix-output-monitor ];
```

**Flake Management**:
```bash
# Show flake structure
nix flake show
# Check flake validity
nix flake check
# Show current inputs
nix flake metadata
# Lock file management
nix flake lock --update-input nixpkgs
nix flake lock --override-input nixpkgs github:NixOS/nixpkgs/branch
```

### DevShell Pattern

**Reproducible development environments**:
```nix
# flake.nix
{
  outputs = { nixpkgs, ... }: {
    devShells.x86_64-linux.default =
      let pkgs = import nixpkgs { system = "x86_64-linux"; };
      in pkgs.mkShell {
        packages = with pkgs; [
          nodejs
          python3
          postgresql
        ];

        shellHook = ''
          echo "Development environment loaded"
          export DATABASE_URL="postgresql://localhost/dev"
        '';
      };
  };
}

# Usage:
# $ nix develop
# Development environment loaded
# $ node --version
```

## Development Workflows

### VM Testing

**Quick disposable testing**:
```bash
# Build VM from current config
nixos-rebuild build-vm --flake .#hostname

# Run (creates qcow2 disk)
./result/bin/run-*-vm

# With specific memory
QEMU_OPTS="-m 4096" ./result/bin/run-*-vm
```

Use for: System-level changes, service testing, migration validation.

### Container Testing (Incus)

**Lightweight persistent environments.**

Why Incus (not LXD):
- Community-led fork post-Canonical acquisition
- Original LXD core team maintains
- Better integration trajectory

```nix
# configuration.nix
virtualisation.incus = {
  enable = true;
  preseed = {
    networks = [{
      name = "incusbr0";
      type = "bridge";
    }];
    storage_pools = [{
      name = "default";
      driver = "dir";
    }];
  };
};

users.users.yourusername.extraGroups = [ "incus-admin" ];
```

**Workflow**:
```bash
# Launch NixOS container
incus launch images:nixos/unstable myproject

# Configure declaratively
incus exec myproject -- bash
cd /etc/nixos
# Edit flake.nix, add configuration
nixos-rebuild switch --flake .#myproject

# Access GUI (if configured with xrdp)
remmina
```

Use cases:
- Isolated client environments
- Testing deployment configs
- Multi-project separation
- Clean state management

## Essential Resources

- Options: https://search.nixos.org/options
- Packages: https://search.nixos.org/packages
- Nix Pills: https://nixos.org/guides/nix-pills/
- Community: discourse.nixos.org
- Weekly education: YouTube "Nix Hour" (@Infinisil)
