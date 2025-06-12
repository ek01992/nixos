{ lib, config, ... }:
let
  cfg = config.my.cli.git;
in
{
  options.my.cli.git = {
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

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;
    };
  };
}