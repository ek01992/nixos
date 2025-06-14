{ config, lib, pkgs, inputs, ... }:
{
  options.services.sops.enable = lib.mkEnableOption "sops";

  imports = [
    inputs.sops-nix.homeModules.sops
  ];

  config = lib.mkIf config.services.sops.enable {
    programs.sops = {
      defaultSopsFile = ../../../../secrets/sops.yaml;
      age.keyFile = "/var/lib/sops/age/keys.txt";
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
}