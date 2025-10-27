# Create a module with standard options structure
{lib, ...}: {
  mkModule = {
    name,
    category,
    config,
    options ? {},
  }: let
    optionName = "${category}.${name}";
    cfg = config.${category}.${name};
  in {
    options.${optionName} =
      {
        enable = lib.mkEnableOption "${name} ${category}";
      }
      // options;

    config = lib.mkIf cfg.enable config;
  };
}
