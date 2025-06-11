{ lib, config, ... }:
{
  options.modules.nixos.ssh.enable = lib.mkEnableOption "openssh server";

  config = lib.mkIf config.modules.nixos.ssh.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}