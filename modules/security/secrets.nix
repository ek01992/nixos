{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.mySecurity.secrets;
  inherit (lib) mkEnableOption mkIf;
in {
  options.mySecurity.secrets = {
    enable = mkEnableOption "Secrets management with agenix";
  };

  config = mkIf cfg.enable {
    age.secrets = {
      # Example: tailscale auth key
      # tailscale-auth.file = ../../secrets/tailscale-auth.age;
    };
  };
}
