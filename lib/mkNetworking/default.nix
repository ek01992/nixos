# Networking helper functions
# Usage: lib.mkBridge { name = "mybridge"; interface = "eth0"; macAddress = "02:00:00:00:00:01"; }
{lib, ...}: {
  # Create a bridge configuration
  mkBridge = {
    name,
    interface,
    macAddress,
    useDhcp ? true,
  }: {
    networking.bridges.${name} = {
      interfaces = [interface];
    };

    networking.interfaces.${name} = {
      useDHCP = lib.mkDefault useDhcp;
      macAddress = macAddress;
    };
  };

  # Create a firewall rule
  mkFirewallRule = {
    port,
    protocol ? "tcp",
    interface ? null,
  }:
    {
      allowedTCPPorts = lib.mkIf (protocol == "tcp") [port];
      allowedUDPPorts = lib.mkIf (protocol == "udp") [port];
    }
    // lib.optionalAttrs (interface != null) {
      trustedInterfaces = [interface];
    };

  # Create a Tailscale configuration
  mkTailscale = {
    enable ? true,
    authKeyFile ? null,
  }: {
    services.tailscale =
      {
        enable = enable;
      }
      // lib.optionalAttrs (authKeyFile != null) {
        inherit authKeyFile;
      };
  };
}
