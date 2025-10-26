{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.server;
in
{
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
    # Import all module categories
    imports = [
      (mkIf cfg.enableSystem ../../modules/system)
      (mkIf cfg.enableNetworking ../../modules/networking)
      (mkIf cfg.enableServices ../../modules/services)
      (mkIf cfg.enableVirtualisation ../../modules/virtualization)
      (mkIf cfg.enableUsers ../../modules/users)
    ];

    # Enable all modules by default
    system.enable = cfg.enableSystem;
    networking.enable = cfg.enableNetworking;
    services.enable = cfg.enableServices;
    virtualisation.enable = cfg.enableVirtualisation;
    users.enable = cfg.enableUsers;

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
