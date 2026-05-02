{ self, inputs, ... }:
{
  flake.nixosModules.niri =
    { pkgs, lib, ... }:
    {
      programs.niri = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
      };

      # xwayland-satellite provides X11 compatibility; niri's wrapper references
      # it by path, so it must be on the system PATH.
      # polkit_gnome provides a graphical auth agent for the user session;
      # its XDG autostart entry is picked up by systemd-xdg-autostart-generator.
      environment.systemPackages = with pkgs; [
        xwayland-satellite
        polkit_gnome
      ];
    };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        settings = {
          spawn-at-startup = [ (lib.getExe self'.packages.myNoctalia) ];
          input.keyboard.xkb.layout = "us";
          layout.gaps = 5;
          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
          binds = {
            "Mod+Return".spawn-sh = lib.getExe pkgs.kitty;
            "Mod+Q".close-window = null;
            "Mod+S".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
          };
        };
      };
    };
}
