{ lib, config, ... }:
{
  options.modules.home-manager.git.enable = lib.mkEnableOption "git";

  config = lib.mkIf config.modules.home-manager.git.enable {
    programs.git = {
      enable = true;
      userName = "ek01992";
      userEmail = "ek01992@proton.me";
    };
  };
}