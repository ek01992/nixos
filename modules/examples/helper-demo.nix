# Example Module Using Helper Functions
# This demonstrates how to use lib helpers for common patterns
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myExamples.helperDemo;
  inherit (lib) mkEnableOption mkOption mkIf types;
in {
  options.myExamples.helperDemo = {
    enable = mkEnableOption "helper function demonstration";

    serviceName = mkOption {
      type = types.str;
      default = "helper-demo";
      description = "Name of the demo service";
    };

    secretFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Secret file to use (relative to secrets/)";
      example = "demo-secret.age";
    };
  };

  config = mkIf cfg.enable {
    # Example 1: Using mkSecretPath for automatic path resolution
    age.secrets = lib.mkIf (cfg.secretFile != null) {
      demo-secret = lib.mkSecretPath {
        name = "demo-secret";
        secretFile = cfg.secretFile;
        owner = "root";
        mode = "0400";
      };
    };

    # Example 2: Using mkSystemdService for a simple service
    systemd.services.${cfg.serviceName} = lib.mkSystemdService {
      name = cfg.serviceName;
      description = "Helper Demo Service";
      script = "${pkgs.bash}/bin/bash -c 'echo Hello from helper demo'";
      serviceConfig = {
        User = "root";
        Group = "root";
      };
    };

    # Example 3: Using mkBridge for networking
    networking.bridges.demo-bridge = lib.mkBridge {
      name = "demo-bridge";
      interface = "eth0";
      macAddress = "02:00:00:00:00:02";
      useDhcp = true;
    };

    # Example 4: Using mkFirewallRule
    networking.firewall.allowedTCPPorts =
      lib.mkFirewallRule
      {
        port = 8080;
        protocol = "tcp";
      }.allowedTCPPorts;

    # Example 5: Using mkTailscale
    services.tailscale = lib.mkTailscale {
      enable = true;
      authKeyFile =
        lib.mkIf (cfg.secretFile != null)
        config.age.secrets.demo-secret.path;
    };
  };
}
