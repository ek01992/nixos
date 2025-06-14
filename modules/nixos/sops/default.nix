{ config, lib, pkgs, inputs, ... }:
{
  options.nixos.sops.enable = lib.mkEnableOption "sops";

  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  config = lib.mkIf config.nixos.sops.enable {
    programs.sops = {
      defaultSopsFile = ../../../secrets/sops.yaml;
      age.keyFile = "/var/lib/sops/age/keys.txt";
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
}