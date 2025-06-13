{ inputs, ... }:
{
  nixosSystem = { system, hostName, specialArgs, modules }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        (
          { config, pkgs, ... }:
          {
            networking.hostName = hostName;
            system.stateVersion = "25.05";
          }
        )
      ] ++ modules;
    };
}