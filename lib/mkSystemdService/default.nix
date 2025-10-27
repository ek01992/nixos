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
}
