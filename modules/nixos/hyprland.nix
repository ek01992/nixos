{ lib, config, inputs, username, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options.modules.nixos.hyprland.enable = lib.mkEnableOption "hyprland";

  config = lib.mkIf config.modules.nixos.hyprland.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      settings = {
        "$mod" = "SUPER";
        bind = [
          "$mod, T, exec, /dev/pts/0"
        ];
      };
    };
  };
}