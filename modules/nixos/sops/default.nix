{ config, lib, pkgs, ... }:
{
  options.nixos.sops.enable = lib.mkEnableOption "sops";

  config = lib.mkIf config.nixos.sops.enable {
    sops = {
      defaultSopsFile = ../../../secrets/sops.yaml;
      age.keyFile = "/var/lib/sops/age/keys.txt";
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
}