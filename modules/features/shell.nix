{ self, inputs, ... }:
{
  flake.nixosModules.shell =
    { pkgs, ... }:
    {
      programs.fish.enable = true;

      users.users.erik.shell = pkgs.fish;

      home-manager.users.erik = {
        programs.fish = {
          enable = true;
          shellAliases = {
            nrb = "nixos-rebuild build --flake $HOME/nixos";
            nrs = "sudo nixos-rebuild switch --flake $HOME/nixos";
            nfc = "nix flake check";
            nfu = "nix flake update";
          };
        };

        programs.starship = {
          enable = true;
          enableFishIntegration = true;
        };
      };
    };
}
