# Secrets Implementation Guide

*Documentation for implementing sops-nix secrets management*

## Overview

This guide documents the secrets management implementation strategy, including the critical API fix needed and expansion patterns for additional secrets.

## Current State

### Foundation ✅ Already Correct
- `.sops.yaml` structure perfect
- Age keys configured properly
- File encryption working
- Non-blocking pattern implemented

### The Critical Bug ❌ Needs Fix

**Current Issue** (`hosts/xps/default.nix`):
```nix
# ❌ WRONG API (commented out until ready):
# age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"]
```

**Correct API**:
```nix
# ✅ CORRECT API:
age.keyFile = "/etc/ssh/ssh_host_ed25519_key"
```

## Implementation Steps

### Step 1: Apply the API Fix

**When Ready to Implement** (currently commented out):

```bash
# 1. Uncomment the sops block in hosts/xps/default.nix
# 2. Fix the API
sed -i 's/age.sshKeyPaths = \["/age.keyFile = "/' hosts/xps/default.nix
sed -i 's/"\];/";/' hosts/xps/default.nix

# 3. Verify the fix
grep -A 5 "sops =" hosts/xps/default.nix
```

**Expected Result**:
```nix
sops = {
  defaultSopsFile = ./secrets.yaml;
  age.keyFile = "/etc/ssh/ssh_host_ed25519_key";
  secrets = {
    tailscale-auth = {
      owner = "root";
      mode = "0400";
    };
  };
};
```

### Step 2: Test Secrets Functionality

```bash
# 1. Test decryption
sudo sops -d hosts/xps/secrets.yaml

# 2. Rebuild system
sudo nixos-rebuild switch --flake .#xps

# 3. Verify secret is available
ls -la /run/secrets/tailscale-auth
sudo cat /run/secrets/tailscale-auth  # Should show decrypted key

# 4. Test Tailscale auto-auth
systemctl status tailscaled
tailscale status
```

### Step 3: Verify Non-Blocking Behavior

The Tailscale module implements graceful degradation:

```nix
# From hosts/common/optional/tailscale.nix
authKeyFile = lib.mkIf (
  cfg.useAuthKeyFile &&
  (config.sops.secrets ? tailscale-auth)
) config.sops.secrets.tailscale-auth.path;
```

**Behavior**:
- Secret exists → Automated authentication
- Secret missing → Service starts, requires manual `sudo tailscale up`
- System builds either way → Non-blocking ✓

## Expansion Patterns

### Adding New Secrets

**Step 1: Add Secret to File**
```bash
# Edit the secrets file
sops hosts/xps/secrets.yaml

# Add new secrets:
# database-password: "your-db-password"
# api-token: "your-api-token"
# ssl-cert: |
#   -----BEGIN CERTIFICATE-----
#   ...
```

**Step 2: Configure Secret Usage**
```nix
# In hosts/xps/default.nix
sops.secrets = {
  tailscale-auth = { owner = "root"; };
  database-password = { owner = "postgres"; };
  api-token = { owner = "myapp"; };
  ssl-cert = { owner = "nginx"; };
};
```

**Step 3: Reference in Services**
```nix
# Example: PostgreSQL
services.postgresql = {
  enable = true;
  initialScript = pkgs.writeText "init.sql" ''
    CREATE USER myapp WITH PASSWORD '${config.sops.secrets.database-password.path}';
  '';
};

# Example: Custom Service
systemd.services.myapp = {
  serviceConfig = {
    EnvironmentFile = config.sops.secrets.api-token.path;
  };
};

# Example: Nginx SSL
services.nginx = {
  virtualHosts."example.com" = {
    sslCertificate = config.sops.secrets.ssl-cert.path;
    sslCertificateKey = config.sops.secrets.ssl-key.path;
  };
};
```

### Non-Blocking Service Pattern

**For Services Using Secrets**:
```nix
options.myService = {
  enable = mkEnableOption "My Service";

  useSecret = mkOption {
    type = types.bool;
    default = true;
    description = "Use secret from sops (set to false for manual config)";
  };
};

config = lib.mkIf cfg.enable {
  services.myService = {
    enable = true;

    # Graceful secret handling
    secretFile = lib.mkIf (
      cfg.useSecret &&
      (config.sops.secrets ? my-secret)
    ) config.sops.secrets.my-secret.path;

    # Fallback behavior when secret missing
    fallbackMode = lib.mkIf (!cfg.useSecret) "manual";
  };
};
```

## Testing Procedures

### Test with Secret
```bash
# 1. Ensure secret exists
sudo sops -d hosts/xps/secrets.yaml

# 2. Rebuild
sudo nixos-rebuild switch --flake .#xps

# 3. Verify service behavior
systemctl status my-service
# Should show automated behavior
```

### Test without Secret
```bash
# 1. Comment out secret in sops.secrets
# 2. Rebuild
sudo nixos-rebuild switch --flake .#xps

# 3. Verify graceful degradation
systemctl status my-service
# Should start but require manual configuration
```

## Security Considerations

### Key Management
```bash
# Generate host key (if needed)
nix-shell -p ssh-to-age
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub

# Store private keys securely (password manager, not in repo)
# Only public keys and encrypted files in repository
```

### File Permissions
```nix
sops.secrets.my-secret = {
  owner = "service-user";
  mode = "0400";  # Read-only for owner
  group = "service-group";  # Optional
};
```

### Rotation Strategy
```bash
# 1. Generate new key
sops hosts/xps/secrets.yaml  # Add new secret

# 2. Update service to use new secret
# 3. Rebuild system
# 4. Remove old secret from file
# 5. Commit changes
```

## Troubleshooting

### Common Issues

**Secret Not Found**:
```bash
# Check if secret exists in sops config
grep "my-secret" hosts/xps/default.nix

# Check if file is encrypted
file hosts/xps/secrets.yaml
# Should show "data" not "ASCII text"
```

**Permission Denied**:
```bash
# Check file ownership
ls -la /run/secrets/my-secret

# Verify owner matches service user
systemctl show my-service | grep User
```

**Decryption Fails**:
```bash
# Test decryption manually
sudo sops -d hosts/xps/secrets.yaml

# Check age key file
ls -la /etc/ssh/ssh_host_ed25519_key
```

### Debug Commands
```bash
# Check sops configuration
sops --config .sops.yaml hosts/xps/secrets.yaml

# List all secrets
sudo ls -la /run/secrets/

# Check service environment
systemctl show-environment my-service
```

## Integration with CI/CD

### Pre-Deployment Checks
```bash
# Verify secrets can be decrypted
sudo sops -d hosts/xps/secrets.yaml > /dev/null

# Check flake builds
nix flake check --no-build

# Dry build test
nixos-rebuild dry-build --flake .#xps
```

### Deployment Safety
```bash
# Test activation first
nixos-rebuild test --flake .#xps

# Then apply
nixos-rebuild switch --flake .#xps
```

## Best Practices

### Secret Organization
```
secrets/
├── common.yaml          # Shared across all hosts
└── hosts/
    └── xps.yaml        # Host-specific secrets
```

### Naming Conventions
- Use descriptive names: `database-password`, not `db-pass`
- Include service context: `postgres-admin-password`
- Group related secrets: `ssl-cert`, `ssl-key`

### Documentation
- Document what each secret is used for
- Include rotation schedule
- Note any external dependencies

## Current Implementation Status

### ✅ Completed
- Non-blocking pattern implemented in Tailscale module
- Graceful degradation working
- API fix documented (ready to apply)

### 🔄 Ready to Implement
- Apply `age.keyFile` fix when Tailscale auth key is available
- Test full secrets workflow
- Expand to additional services as needed

### 📋 Future Enhancements
- Add more service integrations
- Implement secret rotation automation
- Add monitoring for secret availability

---

*This guide provides complete implementation details for sops-nix secrets management. The critical API fix is documented but not yet applied, ready for implementation when a real Tailscale auth key is available.*
