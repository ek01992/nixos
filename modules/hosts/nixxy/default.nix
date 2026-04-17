{ self, inputs, ... }: {

  flake.nixosConfigurations.nixxy = inputs.nixpkgs.lib.nixosSystem {
    modules =[
      self.nixosModules.nixxyConfiguration
    ];
  };
}
