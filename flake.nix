{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    inputs.nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
  };

  outputs = inputs: inputs = {
    flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
  };
}
