{ lib, config, inputs, ... }:
let
  cfg = config.my.services.sops;
in
{
  options.my.services.sops.enable = lib.mkEnableOption "sops";

  imports = [
  ];

  config = lib.mkIf cfg.enable {
  };
}