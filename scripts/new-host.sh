#!/usr/bin/env bash
set -euo pipefail

HOSTNAME=""
TYPE="bare-metal"
WAYLAND="false"

usage() {
  echo "Usage: $0 <hostname> [bare-metal|wsl] [--wayland]" >&2
  echo "  Creates modules/hosts/<hostname>/{default,configuration,hardware}.nix" >&2
  echo "  Default type: bare-metal" >&2
  echo "  --wayland: add self.nixosModules.niri import (bare-metal only)" >&2
  exit 1
}

for arg in "$@"; do
  case "$arg" in
    --wayland) WAYLAND="true" ;;
    bare-metal|wsl) TYPE="$arg" ;;
    -*)
      echo "error: unknown flag: $arg" >&2
      usage
      ;;
    *)
      if [[ -z "$HOSTNAME" ]]; then
        HOSTNAME="$arg"
      else
        echo "error: unexpected argument: $arg" >&2
        usage
      fi
      ;;
  esac
done

[[ -z "$HOSTNAME" ]] && { echo "error: hostname is required" >&2; usage; }

HOST_DIR="modules/hosts/$HOSTNAME"
[[ -d "$HOST_DIR" ]] && { echo "error: $HOST_DIR already exists" >&2; exit 1; }

mkdir -p "$HOST_DIR"

# --- default.nix (same for all types) ---
cat > "$HOST_DIR/default.nix" <<'EOF'
{ self, inputs, ... }:
{

  flake.nixosConfigurations.@HOSTNAME@ = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.@HOSTNAME@Configuration
    ];
  };
}
EOF
sed -i "s/@HOSTNAME@/$HOSTNAME/g" "$HOST_DIR/default.nix"

# --- configuration.nix ---
if [[ "$TYPE" == "wsl" ]]; then
  cat > "$HOST_DIR/configuration.nix" <<'EOF'
{ self, inputs, ... }:
{

  flake.nixosModules.@HOSTNAME@Configuration =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      imports = [
        self.nixosModules.@HOSTNAME@Hardware
        inputs.nixos-wsl.nixosModules.default
        self.nixosModules.common
        self.nixosModules.home
        self.nixosModules.shell
        self.nixosModules.editor
      ];

      wsl = {
        enable = true;
        defaultUser = "erik";
        interop.includePath = false;
      };

      networking.hostName = "@HOSTNAME@";

      users = {
        users = {
          erik = {
            isNormalUser = true;
            description = "Erik Kowald";
            extraGroups = [ "wheel" ];
            packages = with pkgs; [
              # Add User-Specific Packages
            ];
          };
        };
      };

      system.stateVersion = "26.05";
    };
}
EOF
else
  cat > "$HOST_DIR/configuration.nix" <<'EOF'
{ self, inputs, ... }:
{

  flake.nixosModules.@HOSTNAME@Configuration =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      imports = [
        self.nixosModules.@HOSTNAME@Hardware
        self.nixosModules.common
        self.nixosModules.home
        self.nixosModules.shell
        self.nixosModules.editor
@NIRI_IMPORT@
      ];

      boot = {
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
      };

      networking = {
        hostName = "@HOSTNAME@";
        networkmanager.enable = true;
      };

      users = {
        users = {
          erik = {
            isNormalUser = true;
            description = "Erik Kowald";
            extraGroups = [
              "networkmanager"
              "wheel"
            ];
            packages = with pkgs; [
              # Add packages
            ];
          };
        };
      };

      system.stateVersion = "26.05";
    };
}
EOF
fi
sed -i "s/@HOSTNAME@/$HOSTNAME/g" "$HOST_DIR/configuration.nix"

# Apply --wayland flag: substitute or delete the niri import placeholder
if [[ "$TYPE" == "bare-metal" ]]; then
  if [[ "$WAYLAND" == "true" ]]; then
    sed -i 's|@NIRI_IMPORT@|        self.nixosModules.niri|' "$HOST_DIR/configuration.nix"
  else
    sed -i '/@NIRI_IMPORT@/d' "$HOST_DIR/configuration.nix"
  fi
fi

# --- hardware.nix ---
if [[ "$TYPE" == "wsl" ]]; then
  cat > "$HOST_DIR/hardware.nix" <<'EOF'
{ self, inputs, ... }:
{

  flake.nixosModules.@HOSTNAME@Hardware =
    {
      config,
      lib,
      pkgs,
      modulesPath,
      ...
    }:
    {
      boot = {
        initrd = {
          availableKernelModules = [ ];
          kernelModules = [ ];
        };
        kernelModules = [ ];
        extraModulePackages = [ ];
      };

      fileSystems = {
        "/mnt/wsl" = {
          device = "none";
          fsType = "tmpfs";
        };

        "/usr/lib/wsl/drivers" = {
          device = "drivers";
          fsType = "9p";
        };

        "/" = {
          device = "/dev/disk/by-uuid/TODO-ROOT-UUID";
          fsType = "ext4";
        };
      };

      swapDevices = [ { device = "/dev/disk/by-uuid/TODO-SWAP-UUID"; } ];
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
EOF
else
  cat > "$HOST_DIR/hardware.nix" <<'EOF'
{ self, inputs, ... }:
{

  flake.nixosModules.@HOSTNAME@Hardware =
    {
      config,
      lib,
      pkgs,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot = {
        initrd = {
          availableKernelModules = [
            # TODO: Add hardware-specific modules
            # Run: nixos-generate-config --show-hardware-config
            # Common: "xhci_pci" "nvme" "usbhid" "uas" "sd_mod"
          ];
          kernelModules = [ ];
        };
        kernelModules = [ ];
        extraModulePackages = [ ];
      };

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-uuid/TODO-ROOT-UUID";
          fsType = "ext4";
        };

        "/boot" = {
          device = "/dev/disk/by-uuid/TODO-BOOT-UUID";
          fsType = "vfat";
          options = [
            "fmask=0077"
            "dmask=0077"
          ];
        };
      };

      swapDevices = [ { device = "/dev/disk/by-uuid/TODO-SWAP-UUID"; } ];
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
EOF
fi
sed -i "s/@HOSTNAME@/$HOSTNAME/g" "$HOST_DIR/hardware.nix"

git add "$HOST_DIR/"

echo "Created:"
echo "  $HOST_DIR/default.nix"
echo "  $HOST_DIR/configuration.nix"
echo "  $HOST_DIR/hardware.nix"
echo ""
echo "Files staged with git add."
echo ""
echo "Next steps:"
if [[ "$TYPE" == "wsl" ]]; then
  echo "  1. Edit hardware.nix — replace TODO-ROOT-UUID and TODO-SWAP-UUID"
  echo "     (run: lsblk -o NAME,UUID)"
else
  echo "  1. Edit hardware.nix — replace TODO-ROOT-UUID, TODO-BOOT-UUID, TODO-SWAP-UUID"
  echo "     (run: lsblk -o NAME,UUID  or: nixos-generate-config --show-hardware-config)"
  echo "  2. Edit hardware.nix — add availableKernelModules for your hardware"
fi
echo "  3. nixfmt-tree"
echo "  4. nix flake check"
echo "  5. nixos-rebuild build --flake .#$HOSTNAME"
