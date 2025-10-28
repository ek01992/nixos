# Common user accounts across all hosts
# Host-specific users or SSH keys go in hosts/<hostname>/
# Verification: id erik, getent passwd erik
{
  config,
  lib,
  pkgs,
  ...
}: {
  users.users.erik = {
    isNormalUser = true;
    description = "Erik Kowald";
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdtT76ryXgblv68mqVfrcRVp4tRvhl81vwFKDLEF0MP desktop@erik-dev.io"
    ];
  };
}
