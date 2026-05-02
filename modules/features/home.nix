{ self, inputs, ... }:
{
  flake.nixosModules.home =
    { ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users.erik = {
          home = {
            username = "erik";
            homeDirectory = "/home/erik";
            stateVersion = "26.05";
          };
        };
      };
    };
}
