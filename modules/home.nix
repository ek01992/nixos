# This file configures Home Manager for your NixOS system.
{ ... }:
{
  home-manager = {
    # This is needed to make home-manager use the same pkgs defined in your flake.
    useGlobalPkgs = true;
    # This allows home-manager to manage packages for each user.
    useUserPackages = true;
    # Link the user `erik` to his home-manager configuration.
    users.erik = import ./users/home.nix;
  };
}