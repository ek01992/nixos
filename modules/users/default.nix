{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.users;
in
{
  options.users = {
    enable = mkEnableOption "users configuration";

    enableErik = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Erik user account";
    };
  };

  imports = [
    ./erik.nix
  ];

  config = mkIf cfg.enable {
  };
}
