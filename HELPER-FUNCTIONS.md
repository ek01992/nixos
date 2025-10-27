# Helper Functions Documentation

This document provides comprehensive documentation for the helper functions available in this NixOS configuration.

## Overview

Helper functions are located in `lib/default.nix` and provide common patterns for:
- Module creation
- Secret management
- Systemd service configuration
- Networking setup

## Module Helpers

### `lib.mkModule`

Creates a standard module with options and configuration.

**Parameters:**
- `name` (string): Name of the feature
- `category` (string): Category namespace (e.g., "myServices")
- `config` (attribute set): Configuration to apply when enabled
- `options` (attribute set, optional): Additional options to define

**Example:**
```nix
lib.mkModule {
  name = "myfeature";
  category = "myServices";
  config = {
    services.myfeature.enable = true;
  };
  options = {
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to listen on";
    };
  };
}
```

### `lib.mkServiceModule`

Creates a module with systemd service integration.

**Parameters:**
- `name` (string): Name of the service
- `category` (string): Category namespace
- `serviceName` (string): Systemd service name
- `description` (string): Service description
- `config` (attribute set, optional): Additional service configuration
- `options` (attribute set, optional): Additional options

**Example:**
```nix
lib.mkServiceModule {
  name = "myservice";
  category = "myServices";
  serviceName = "my-service";
  description = "My Custom Service";
  config = {
    ExecStart = "/path/to/script";
    User = "myuser";
  };
}
```

## Secret Helpers

### `lib.mkSecret`

Creates a secret configuration for agenix.

**Parameters:**
- `name` (string): Secret name
- `file` (string): Path to encrypted secret file
- `owner` (string, optional): File owner (default: "root")
- `mode` (string, optional): File permissions (default: "0400")
- `group` (string, optional): File group

**Example:**
```nix
lib.mkSecret {
  name = "mysecret";
  file = "../../secrets/mysecret.age";
  owner = "root";
  mode = "0400";
}
```

### `lib.mkSecretPath`

Creates a secret with automatic path resolution to `secrets/` directory.

**Parameters:**
- `name` (string): Secret name
- `secretFile` (string): Filename in secrets/ directory
- `owner` (string, optional): File owner (default: "root")
- `mode` (string, optional): File permissions (default: "0400")
- `group` (string, optional): File group

**Example:**
```nix
lib.mkSecretPath {
  name = "mysecret";
  secretFile = "mysecret.age";  # Resolves to ../../secrets/mysecret.age
}
```

### `lib.mkSecrets`

Creates multiple secrets from a list.

**Parameters:**
- `secrets` (list): List of secret configurations

**Example:**
```nix
lib.mkSecrets [
  { name = "secret1"; file = "../../secrets/secret1.age"; }
  { name = "secret2"; file = "../../secrets/secret2.age"; }
]
```

## Systemd Service Helpers

### `lib.mkSystemdService`

Creates a oneshot systemd service.

**Parameters:**
- `name` (string): Service name
- `description` (string): Service description
- `script` (string): Command to execute
- `serviceConfig` (attribute set, optional): Additional service configuration

**Example:**
```nix
lib.mkSystemdService {
  name = "myservice";
  description = "My Service";
  script = "/path/to/script";
  serviceConfig = {
    User = "myuser";
    WorkingDirectory = "/path/to/workdir";
  };
}
```

### `lib.mkSystemdServiceRestart`

Creates a systemd service with restart behavior.

**Parameters:**
- `name` (string): Service name
- `description` (string): Service description
- `script` (string): Command to execute
- `restart` (string, optional): Restart policy (default: "on-failure")
- `serviceConfig` (attribute set, optional): Additional service configuration

**Example:**
```nix
lib.mkSystemdServiceRestart {
  name = "myservice";
  description = "My Service";
  script = "/path/to/script";
  restart = "always";
}
```

### `lib.mkSystemdTimer`

Creates a systemd timer service.

**Parameters:**
- `name` (string): Timer name
- `description` (string): Timer description
- `script` (string): Command to execute
- `onCalendar` (string): Calendar specification
- `serviceConfig` (attribute set, optional): Additional service configuration

**Example:**
```nix
lib.mkSystemdTimer {
  name = "mytimer";
  description = "My Timer";
  script = "/path/to/script";
  onCalendar = "daily";
}
```

## Networking Helpers

### `lib.mkBridge`

Creates a bridge network configuration.

**Parameters:**
- `name` (string): Bridge name
- `interface` (string): Physical interface to bridge
- `macAddress` (string): MAC address for bridge
- `useDhcp` (boolean, optional): Enable DHCP (default: true)

**Example:**
```nix
lib.mkBridge {
  name = "mybridge";
  interface = "eth0";
  macAddress = "02:00:00:00:00:01";
  useDhcp = true;
}
```

### `lib.mkFirewallRule`

Creates a firewall rule configuration.

**Parameters:**
- `port` (integer): Port number
- `protocol` (string, optional): Protocol (default: "tcp")
- `interface` (string, optional): Trusted interface

**Example:**
```nix
lib.mkFirewallRule {
  port = 8080;
  protocol = "tcp";
  interface = "tailscale0";
}
```

### `lib.mkTailscale`

Creates a Tailscale configuration.

**Parameters:**
- `enable` (boolean, optional): Enable Tailscale (default: true)
- `authKeyFile` (string, optional): Path to auth key file

**Example:**
```nix
lib.mkTailscale {
  enable = true;
  authKeyFile = "/path/to/key";
}
```

## Best Practices

### When to Use Helpers

**Use helpers when:**
- Creating standard module patterns
- Managing secrets with agenix
- Setting up common systemd services
- Configuring standard networking components

**Don't use helpers when:**
- Configuration is highly custom
- You need fine-grained control
- The helper doesn't fit your use case
- Performance is critical

### Helper Composition

Helpers can be composed and combined:

```nix
# Combine multiple helpers
config = lib.mkIf cfg.enable {
  # Use secret helper
  age.secrets = {
    mysecret = lib.mkSecretPath {
      name = "mysecret";
      secretFile = "mysecret.age";
    };
  };

  # Use service helper
  systemd.services.myservice = lib.mkSystemdService {
    name = "myservice";
    description = "My Service";
    script = "/path/to/script";
  };

  # Use networking helper
  networking.bridges.mybridge = lib.mkBridge {
    name = "mybridge";
    interface = "eth0";
    macAddress = "02:00:00:00:00:01";
  };
};
```

## Migration Guide

### From Manual Configuration

**Before (manual):**
```nix
config = mkIf cfg.enable {
  age.secrets.mysecret = {
    file = ../../secrets/mysecret.age;
    owner = "root";
    mode = "0400";
  };
};
```

**After (with helper):**
```nix
config = mkIf cfg.enable {
  age.secrets.mysecret = lib.mkSecretPath {
    name = "mysecret";
    secretFile = "mysecret.age";
  };
};
```

### Benefits

- **Consistency**: All modules follow the same patterns
- **Reduced boilerplate**: Less repetitive code
- **Type safety**: Helpers provide better error messages
- **Documentation**: Built-in examples and patterns
- **Maintainability**: Changes to patterns affect all modules
