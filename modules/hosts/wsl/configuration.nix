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
        self.nixosModules.home
        self.nixosModules.shell
        self.nixosModules.editor
      ];

      wsl = {
        enable = true;
        defaultUser = "erik";
        interop.includePath = false;
      };

      networking.hostName = "nixos-wsl";

      hardware.nvidia-container-toolkit = {
        enable = true;
        suppressNvidiaDriverAssertion = true;
        mount-nvidia-executables = true;
      };

      environment.variables = {
        LD_LIBRARY_PATH = "/usr/lib/wsl/lib";
        CUDA_PATH = "/usr/lib/wsl";
      };

      nix.settings = {
        cores = 12;
        max-jobs = 2;
        auto-optimise-store = true;
      };

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
