{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.server;
in
{
  imports = [
    ../../modules/system
    ../../modules/networking
    ../../modules/services
    ../../modules/virtualization
    ../../modules/users
  ];

  options.profiles.server = {
    enable = mkEnableOption "server profile with all standard modules";
  };

  config = mkIf cfg.enable {
    # Just enable everything - granular control via mySystem.* options
    mySystem.enable = true;
    myNetworking.enable = true;
    myServices.enable = true;
    myVirtualization.enable = true;
    myUsers.enable = true;

    environment.systemPackages = with pkgs; [
      git
      wget
      curl
      htop
      vim
      tree
      alejandra
    ];
  };
}
