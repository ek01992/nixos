{ lib, config, pkgs, ... }:

let
  cfg = config.nixos.power-management;
in
{
  options.nixos.power-management.enable = lib.mkEnableOption "power management settings for laptops";

  config = lib.mkIf cfg.enable {

    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_HWP_DYN_BOOST_ON_AC = 1;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;
        PCIE_ASPM_ON_BAT = "powersupersave";
      };
    };

    services.thermald.enable = true;
    services.power-profiles-daemon.enable = false;
    powerManagement.powertop = {
      autoTune.enable = true;
      enable = true;
    };
  };
}