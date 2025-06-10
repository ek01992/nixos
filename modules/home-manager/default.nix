{ ... }: 
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.erik = import ../../users/erik/home.nix;
  };
}