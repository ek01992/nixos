{ lib, config, ... }:
let
  cfg = config.my.nixos.ssh;
in
{
  options.my.nixos.ssh.enable = lib.mkEnableOption "openssh server";

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