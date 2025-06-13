{ lib, config, ... }:
let
  cfg = config.nixos.ssh;
in
{
  options.nixos.ssh.enable = lib.mkEnableOption "openssh server";

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}