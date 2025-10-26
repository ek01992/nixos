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
    enable = mkEnableOption "server profile";

    enableSystem = mkOption {
      type = types.bool;
      default = true;
      description = "Enable system configuration";
    };

    enableNetworking = mkOption {
      type = types.bool;
      default = true;
      description = "Enable networking configuration";
    };

    enableServices = mkOption {
      type = types.bool;
      default = true;
      description = "Enable services configuration";
    };

    enableVirtualisation = mkOption {
      type = types.bool;
      default = true;
      description = "Enable virtualisation configuration";
    };

    enableUsers = mkOption {
      type = types.bool;
      default = true;
      description = "Enable users configuration";
    };

    enableSystemPackages = mkOption {
      type = types.bool;
      default = true;
      description = "Enable essential system packages";
    };
  };

  config = mkIf cfg.enable {
    # Enable all modules by default
    mySystem.enable = cfg.enableSystem;
    myNetworking.enable = cfg.enableNetworking;
    myServices.enable = cfg.enableServices;
    myVirtualisation.enable = cfg.enableVirtualisation;
    myUsers.enable = cfg.enableUsers;

    # Essential system packages for server use
    environment.systemPackages = mkIf cfg.enableSystemPackages (with pkgs; [
      git
      wget
      curl
      htop
      vim
      tree
    ]);
  };
}
