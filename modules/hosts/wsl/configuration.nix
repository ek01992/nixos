{ self, inputs, ... }:
{

  flake.nixosModules.nixos-wslConfiguration =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      imports = [
        self.nixosModules.nixos-wslHardware
        inputs.nixos-wsl.nixosModules.default
        self.nixosModules.common
      ];

      wsl = {
        enable = true;
        defaultUser = "erik";
        interop.includePath = false;
      };

      programs = {
        # programName = {
        #   enable = true;
        #   ...
        # };
      };

      services = {
        # serviceName = {
        #   enable = true;
        #   ...
        # };
      };

      networking.hostName = "nixos-wsl";

      users = {
        users = {
          erik = {
            isNormalUser = true;
            description = "Erik Kowald";
            extraGroups = [ "wheel" ];
            packages = with pkgs; [
              # Add User-Specific Packages
            ];
          };
        };
      };

      system.stateVersion = "26.05";
    };
}
