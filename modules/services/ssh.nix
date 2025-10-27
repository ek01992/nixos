# SSH Service Module
# Verification: systemctl status sshd
#               ss -tlnp | grep :22
#               ssh-audit localhost
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myServices.ssh;
  inherit (lib) mkEnableOption mkOption mkIf types mkDefault;
in {
  options.myServices.ssh = {
    enable = mkEnableOption "SSH daemon";

    port = mkOption {
      type = types.int;
      default = 22;
      description = "SSH daemon port";
      example = 2222;
    };

    passwordAuthentication = mkOption {
      type = types.bool;
      default = false;
      description = "Allow password authentication";
    };

    kbdInteractiveAuthentication = mkOption {
      type = types.bool;
      default = false;
      description = "Allow keyboard interactive authentication";
    };

    permitRootLogin = mkOption {
      type = types.enum ["yes" "no" "prohibit-password" "forced-commands-only"];
      default = "no";
      description = "Permit root login";
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = lib.mkDefault true;
      settings = lib.mkDefault {
        Port = cfg.port;
        PasswordAuthentication = cfg.passwordAuthentication;
        KbdInteractiveAuthentication = cfg.kbdInteractiveAuthentication;
        PermitRootLogin = cfg.permitRootLogin;
      };
    };
  };
}
