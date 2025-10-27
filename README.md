# NixOS Personal Homelab

A modular NixOS configuration for a personal laptop homelab/server with Incus container and VM management.

## Quick Start

1. **Prerequisites**: Nix with flakes enabled
2. **Clone**: `git clone <repo-url> && cd nixos`
3. **Build**: `just build`
4. **Switch**: `sudo just switch`
5. **Update**: `just update`

## Secrets Management

This configuration uses agenix for encrypted secrets management.

### Setup
1. **Generate age key**: `sudo mkdir -p /var/lib/agenix && sudo age-keygen -o /var/lib/agenix/key.txt`
2. **Add to host config**: `age.identityPaths = [ "/var/lib/agenix/key.txt" ];`
3. **Encrypt secrets**: `agenix -e secrets/tailscale-auth.age`
4. **Enable in host**: `mySecurity.secrets.enable = true;`

### Available Secrets
- **Tailscale auth key**: Automatic VPN login
- **SSH host key**: Consistent host identification

See [secrets/README.md](secrets/README.md) for detailed instructions.

## Structure

This configuration uses a modular flake architecture:

- **`flake.nix`**: Entry point with `mkSystem` helper for multi-host support
- **`hosts/`**: Host-specific configurations (hardware, networking, mounts)
- **`modules/`**: Reusable NixOS modules (system, networking, services, virtualization, users)

## Common Tasks

Use `just` for common operations:

```bash
just              # List all available tasks
just build        # Build system configuration
just switch       # Apply configuration to system
just update       # Update flake inputs
just check        # Validate syntax and structure
just fmt          # Format all .nix files
just clean        # Garbage collect old generations
```

## Features

- **Incus Integration**: Container and VM management with web UI
- **ZFS Support**: Automatic scrubbing and trimming
- **Tailscale VPN**: Secure remote access
- **Modular Design**: Easy to add hosts and modules
- **Hardware Support**: Dell XPS 13 9315 optimizations

## Adding Components

- **New Host**: Create `hosts/hostname/`, add to `flake.nix`
- **New Module**: Create in `modules/category/`, import in host

See [AGENTS.md](AGENTS.md) for detailed patterns and [CONTRIBUTING.md](CONTRIBUTING.md) for workflow guidelines.

## Backup Strategy

This configuration uses ZFS for storage management with automatic maintenance, but **ZFS scrubbing ≠ backups**.

### Current Setup

- **ZFS snapshots**: Manual via `zfs snapshot tank@backup-$(date +%Y%m%d)`
- **Automatic maintenance**: Scrubbing and trimming enabled
- **Off-host backups**: Not yet implemented

### Future Considerations

- **sanoid + syncoid**: Automated ZFS snapshots and replication to remote ZFS
- **restic**: Encrypted backups to cloud storage (Backblaze B2, AWS S3)
- **borg**: Deduplicated backups with compression

### Manual Backup Commands
```bash
# Create ZFS snapshot
zfs snapshot tank@backup-$(date +%Y%m%d)

# List snapshots
zfs list -t snapshot

# Send snapshot to remote (when configured)
zfs send tank@backup-20251026 | ssh remote-host "zfs receive tank/backup"
```

## Current Hosts

- **xps**: Dell XPS 13 9315 laptop with Incus virtualization
