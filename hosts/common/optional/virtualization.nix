# Virtualization stack (Incus + KVM-GT)
# Enable in host config with: imports = [ ../common/optional/virtualization.nix ];
# Verification: incus list, systemctl status incus

{
  config,
  lib,
  pkgs,
  ...
}: {

  # Intel GVT-g GPU virtualization
  virtualisation.kvmgt.enable = true;

  # Incus container and VM management
  virtualisation.incus = {
    enable = true;
    package = pkgs.incus;
    ui.enable = true;
    preseed = {
      networks = [
        {
          name = "internalbr0";
          type = "bridge";
          description = "Internal/NATted bridge";
          config = {
            "ipv4.address" = "auto";
            "ipv4.nat" = "true";
            "ipv6.address" = "auto";
            "ipv6.nat" = "true";
          };
        }
      ];
      profiles = [
        {
          name = "default";
          description = "Default Incus Profile";
          devices = {
            eth0 = {
              name = "eth0";
              network = "internalbr0";
              type = "nic";
            };
            root = {
              path = "/";
              pool = "default";
              type = "disk";
            };
          };
        }
        {
          name = "bridged";
          description = "Instances bridged to LAN";
          devices = {
            eth0 = {
              name = "eth0";
              nictype = "bridged";
              parent = "externalbr0";
              type = "nic";
            };
            root = {
              path = "/";
              pool = "default";
              type = "disk";
            };
          };
        }
      ];
      storage_pools = [
        {
          name = "default";
          driver = "zfs";
          config = {
            source = "tank/incus";
          };
        }
      ];
    };
  };

  # Add incus-admin group
  users.users.erik.extraGroups = lib.mkAfter ["incus-admin"];

  # Trust external bridge in firewall if it exists
  networking.firewall.trustedInterfaces = lib.mkAfter (
    lib.optional (config.networking.bridges ? externalbr0) "externalbr0"
  );

}
