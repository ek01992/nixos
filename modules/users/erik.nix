{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myUsers.erik;
  inherit (lib) mkEnableOption mkOption mkIf types;
in {
  options.myUsers.erik = {
    enable = mkEnableOption "Erik user account";

    description = mkOption {
      type = types.str;
      default = "Erik Kowald";
      description = "User description";
      example = "John Doe";
    };

    extraGroups = mkOption {
      type = types.listOf types.str;
      default = ["wheel" "incus-admin"];
      description = "Additional groups for Erik user";
      example = ["wheel" "docker" "audio"];
    };

    sshKeys = mkOption {
      type = types.listOf types.str;
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdtT76ryXgblv68mqVfrcRVp4tRvhl81vwFKDLEF0MP desktop@erik-dev.io"
      ];
      description = "SSH public keys for Erik user";
    };
  };

  config = mkIf cfg.enable {
    users.users.erik = {
      isNormalUser = true;
      description = cfg.description;
      extraGroups = cfg.extraGroups;
      openssh.authorizedKeys.keys = cfg.sshKeys;
    };
  };
}
