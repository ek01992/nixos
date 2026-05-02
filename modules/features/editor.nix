{ self, inputs, ... }:
{
  flake.nixosModules.editor =
    { ... }:
    {
      home-manager.users.erik.programs.helix = {
        enable = true;
        defaultEditor = true;
      };
    };
}
