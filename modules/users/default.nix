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

  config = mkIf cfg.enable {
    # Import user modules
    imports = [
      (mkIf cfg.enableErik ./erik.nix)
    ];
  };
}
