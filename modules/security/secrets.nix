# Secrets Management Module
# Verification: age --decrypt secrets/tailscale-auth.age
#               ls -la /run/secrets/
#               systemctl status age-secrets
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.mySecurity.secrets;
  inherit (lib) mkEnableOption mkIf mkOption types;
in {
  options.mySecurity.secrets = {
    enable = mkEnableOption "Secrets management with agenix";

    tailscaleAuthKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Tailscale auth key file path (relative to secrets/)";
      example = "tailscale-auth.age";
    };

    sshHostKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "SSH host key file path (relative to secrets/)";
      example = "ssh-host-key.age";
    };
  };

  config = mkIf cfg.enable {
    age.secrets = {
      # Tailscale auth key for automatic login
      tailscale-auth = lib.mkIf (cfg.tailscaleAuthKey != null) {
        file = ../../secrets/${cfg.tailscaleAuthKey};
        owner = "root";
        mode = "0400";
      };

      # SSH host key for consistent host identification
      ssh-host-key = lib.mkIf (cfg.sshHostKey != null) {
        file = ../../secrets/${cfg.sshHostKey};
        owner = "root";
        mode = "0400";
      };
    };

    # Use secrets in services
    services.tailscale.authKeyFile =
      lib.mkIf (cfg.tailscaleAuthKey != null)
      config.age.secrets.tailscale-auth.path;
  };
}
