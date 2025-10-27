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
  # Usage: lib.mkServiceModule { name = "myservice"; category = "myservices"; serviceName = "myservice"; description = "My Service"; config = {...}; }
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
    options.${optionName} =
      {
        enable = lib.mkEnableOption "${description}";
      }
      // options;

    config = lib.mkIf cfg.enable {
      systemd.services.${serviceName} =
        {
          description = description;
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
        }
        // config;
    };
  };
}
