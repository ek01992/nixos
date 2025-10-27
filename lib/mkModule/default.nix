# Create a module with standard options structure
# Usage: lib.mkModule { name = "myfeature"; category = "myCategory"; config = {...}; }
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

  # Create a simple service module with common patterns
  mkServiceModule = {
    name,
    category,
    serviceName,
    description,
    config ? {},
    options ? {},
  }: let
    optionName = "${category}.${name}";
    cfg = config.${category}.${name};
  in {
    options.${optionName} = {
      enable = lib.mkEnableOption "${description}";
    } // options;

    config = lib.mkIf cfg.enable {
      systemd.services.${serviceName} = {
        description = description;
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      } // config;
    };
  };
}
