{ lib, config, ... }:
{
  options.modules.home-manager.cli.git = {
    enable = lib.mkEnableOption "git";

    userName = lib.mkOption {
      type = lib.types.str;
      description = "The user name to use for git commits.";
    };

    userEmail = lib.mkOption {
      type = lib.types.str;
      description = "The user email to use for git commits.";
    };
  };

  config = lib.mkIf config.modules.home-manager.cli.git.enable {
    programs.git = {
      enable = true;
      userName = config.modules.home-manager.cli.git.userName;
      userEmail = config.modules.home-manager.cli.git.userEmail;
    };
  };
}