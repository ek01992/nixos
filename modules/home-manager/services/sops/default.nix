{ lib, config, inputs, ... }:
let
  cfg = config.services.sops;
in
{
  options.services.sops.enable = lib.mkEnableOption "sops";

  imports = [
  ];

  config = lib.mkIf cfg.enable {
  };
}