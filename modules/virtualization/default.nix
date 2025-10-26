{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.virtualisation;
in
{
  options.virtualisation = {
    enable = mkEnableOption "virtualisation configuration";

    enableKvmgt = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Intel GVT-g GPU virtualization";
    };

    enableIncus = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Incus container and VM management";
    };
  };

  config = mkIf cfg.enable {
    # Import virtualization modules
    imports = [
      (mkIf cfg.enableKvmgt ./kvmgt.nix)
      (mkIf cfg.enableIncus ./incus.nix)
    ];
  };
}
