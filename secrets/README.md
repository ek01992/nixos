# Secrets Directory

This directory contains encrypted secrets managed by agenix.

## Setup Instructions

### 1. Generate Age Key
```bash
# Create age key directory
sudo mkdir -p /var/lib/agenix
sudo age-keygen -o /var/lib/agenix/key.txt

# Add to host configuration
age.identityPaths = [ "/var/lib/agenix/key.txt" ];
```

### 2. Encrypt Secrets
```bash
# Encrypt a secret file
agenix -e secrets/tailscale-auth.age

# Edit the file and add your secret
# Save and exit - file is automatically encrypted
```

### 3. Enable in Host Configuration
```nix
mySecurity.secrets = {
  enable = true;
  tailscaleAuthKey = "tailscale-auth.age";
  sshHostKey = "ssh-host-key.age";
};
```

## Available Secrets

- `tailscale-auth.age` - Tailscale auth key for automatic login
- `ssh-host-key.age` - SSH host key for consistent identification

## Security Notes

- Never commit unencrypted secrets
- Use strong, unique age keys
- Rotate secrets regularly
- Monitor access logs
