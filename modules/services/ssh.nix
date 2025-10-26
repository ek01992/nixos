{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ssh;
in
{
  options.services.ssh = {
    enable = mkEnableOption "SSH daemon";

    port = mkOption {
      type = types.int;
      default = 22;
      description = "SSH daemon port";
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
      type = types.enum [ "yes" "no" "prohibit-password" "forced-commands-only" ];
      default = "no";
      description = "Permit root login";
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        Port = cfg.port;
        PasswordAuthentication = cfg.passwordAuthentication;
        KbdInteractiveAuthentication = cfg.kbdInteractiveAuthentication;
        PermitRootLogin = cfg.permitRootLogin;
      };
    };
  };
}
