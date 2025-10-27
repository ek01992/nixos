# Users Configuration Module
# Verification: id erik
#               groups erik
#               ls -la /home/erik/.ssh/authorized_keys
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myUsers;
  inherit (lib) mkEnableOption;
in {
  options.myUsers = {
    enable = mkEnableOption "users configuration";
  };

  imports = [
    ./erik
  ];
}
