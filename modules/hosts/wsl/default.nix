{ self, inputs, ... }: {

  flake.nixosConfigurations.nixos-wsl = inputs.nixpkgs.lib.nixosSystem {
    modules =[
      self.nixosModules.nixos-wslConfiguration
      inputs.nixos-wsl.nixosModules.default
    ];
  };
}
