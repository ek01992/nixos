{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    programs.zoxide.enableZshIntegration = true;
    programs.zoxide.enable = true;
  };
}