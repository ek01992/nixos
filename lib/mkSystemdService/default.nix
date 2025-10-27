# Create a systemd service with common patterns
# Usage: lib.mkSystemdService { name = "myservice"; description = "My Service"; script = "echo hello"; }
{lib, ...}: {
  # Create a systemd service with common patterns
  mkSystemdService = {
    name,
    description,
    script,
    serviceConfig ? {},
  }: {
    description = description;
    wantedBy = ["multi-user.target"];
    serviceConfig =
      {
        Type = "oneshot";
        ExecStart = script;
        RemainAfterExit = true;
      }
      // serviceConfig;
  };

  # Create a systemd service with restart behavior
  mkSystemdServiceRestart = {
    name,
    description,
    script,
    restart ? "on-failure",
    serviceConfig ? {},
  }: {
    description = description;
    wantedBy = ["multi-user.target"];
    serviceConfig =
      {
        Type = "simple";
        ExecStart = script;
        Restart = restart;
        RestartSec = "5s";
      }
      // serviceConfig;
  };

  # Create a systemd timer service
  mkSystemdTimer = {
    name,
    description,
    script,
    onCalendar,
    serviceConfig ? {},
  }: {
    systemd.services.${name} = {
      description = description;
      serviceConfig =
        {
          Type = "oneshot";
          ExecStart = script;
        }
        // serviceConfig;
    };

    systemd.timers.${name} = {
      description = description;
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = onCalendar;
        Persistent = true;
      };
    };
  };
}
