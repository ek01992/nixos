# Users Configuration Module
# Verification: id erik
#               groups erik
#               ls -la /home/erik/.ssh/authorized_keys
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myUsers;
in {
  options.myUsers = {
    enable = mkEnableOption "users configuration";
  };

  imports = [
    ./erik.nix
  ];
}
