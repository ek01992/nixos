# Lib Helper Functions
# Provides common patterns and abstractions for NixOS modules
{
  lib,
  ...
}: {
  # Create a module with standard options structure
  mkModule = { name, category, config, options ? {} }:
    let
      optionName = "${category}.${name}";
      cfg = config.${category}.${name};
    in {
      options.${optionName} = {
        enable = lib.mkEnableOption "${name} ${category}";
      } // options;

      config = lib.mkIf cfg.enable config;
    };

  # Create a secret with standard age.secrets structure
  mkSecret = { name, file, owner ? "root", mode ? "0400", group ? null }:
    {
      file = file;
      owner = owner;
      mode = mode;
    } // lib.optionalAttrs (group != null) { inherit group; };

  # Create a systemd service with common patterns
  mkSystemdService = { name, description, script, serviceConfig ? {} }:
    {
      description = description;
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = script;
        RemainAfterExit = true;
      } // serviceConfig;
    };
}
