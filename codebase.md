# flake.nix

```nix
{ description = "flake for nixos with Home Manager enabled"; outputs = { self, nixpkgs, home-manager, nixos-hardware, stylix, nur, ... }@inputs: let lib = import ./lib { inherit inputs; }; in { nixosModules.default = import ./modules/nixos; homeModules.default = import ./modules/home-manager; nixosConfigurations = { xps = lib.nixosSystem { system = "x86_64-linux"; hostName = "xps"; specialArgs = { inherit inputs; }; modules = [ ./hosts/xps/configuration.nix ]; }; }; }; inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; nixos-hardware.url = "github:NixOS/nixos-hardware"; hyprland.url = "github:hyprwm/Hyprland"; home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; }; stylix = { url = "github:nix-community/stylix"; inputs.nixpkgs.follows = "nixpkgs"; }; nixvim = { url = "github:nix-community/nixvim"; inputs.nixpkgs.follows = "nixpkgs"; }; nur = { url = "github:nix-community/NUR"; inputs.nixpkgs.follows = "nixpkgs"; }; }; }
```

# hosts/xps/configuration.nix

```nix
{ config, pkgs, inputs, lib, ... }: let users = [ "erik" ]; in { imports = [ ./hardware-configuration.nix inputs.self.nixosModules.default ] ++ (map (username: ../../users + "/${username}/default.nix") users); nixos = { core.enable = true; home-manager.enable = true; ssh.enable = true; hyprland.enable = true; zsh.enable = true; greetd = { enable = true; user = "erik"; }; obsidian.enable = true; nixvim.enable = true; power-management.enable = true; }; home-manager = { extraSpecialArgs = { inherit inputs; }; users = lib.genAttrs users (username: { imports = [ ../../users/${username}/home.nix ]; }); }; users = { users = lib.genAttrs users (username: { isNormalUser = true; createHome = true; }); }; }
```

# hosts/xps/hardware-configuration.nix

```nix
{ config, lib, pkgs, modulesPath, inputs, ... }: { imports = [ (modulesPath + "/installer/scan/not-detected.nix") inputs.nixos-hardware.nixosModules.dell-xps-13-9315 ]; boot = { consoleLogLevel = 3; kernelParams = [ "quiet" "splash" "boot.shell_on_fail" "udev.log_priority=3" "rd.systemd.show_status=auto" "i915.enable_psr=0" ]; initrd = { availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "uas" "sd_mod" ]; kernelModules = [ ]; verbose = false; }; loader = { systemd-boot = { enable = true; configurationLimit = 5; }; timeout = 0; efi.canTouchEfiVariables = true; }; kernelModules = [ "kvm-intel" ]; blacklistedKernelModules = [ "psmouse" ]; extraModulePackages = [ ]; plymouth = { enable = true; }; kernelPackages = pkgs.linuxPackages_latest; }; fileSystems = { "/" = { device = "/dev/disk/by-uuid/a4f2ee31-d059-4bdd-8ded-8c0a9da26b80"; fsType = "ext4"; }; "/boot" = { device = "/dev/disk/by-uuid/5085-7E42"; fsType = "vfat"; options = [ "fmask=0077" "dmask=0077" ]; }; }; swapDevices = [ { device = "/dev/disk/by-uuid/3bf3ac89-468c-4007-856a-d18ed360def8"; } ]; networking = { useDHCP = lib.mkDefault true; networkmanager = { enable = true; wifi.powersave = true; }; }; nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux"; hardware = { firmware = with pkgs; [ sof-firmware ]; cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware; graphics = let pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}; in { enable = true; enable32Bit = true; package = pkgs-unstable.mesa; package32 = pkgs-unstable.pkgsi686Linux.mesa; extraPackages = with pkgs; [ intel-media-driver vaapiIntel vaapiVdpau libvdpau-va-gl ]; extraPackages32 = with pkgs.pkgsi686Linux; [ intel-media-driver vaapiIntel vaapiVdpau libvdpau-va-gl ]; }; }; }
```

# lib/default.nix

```nix
{ inputs, ... }: { nixosSystem = { system, hostName, specialArgs, modules }: inputs.nixpkgs.lib.nixosSystem { inherit system specialArgs; modules = [ ( { config, pkgs, ... }: { networking.hostName = hostName; system.stateVersion = "25.05"; } ) ] ++ modules; }; }
```

# modules/home-manager/cli/default.nix

```nix
{ imports = [ ./git ./zsh ./zoxide ]; }
```

# modules/home-manager/cli/git/default.nix

```nix
{ lib, config, ... }: let cfg = config.cli.git; in { options.cli.git = { enable = lib.mkEnableOption "git"; userName = lib.mkOption { type = lib.types.str; description = "The user name to use for git commits."; }; userEmail = lib.mkOption { type = lib.types.str; description = "The user email to use for git commits."; }; }; config = lib.mkIf cfg.enable { programs.git = { enable = true; userName = cfg.userName; userEmail = cfg.userEmail; }; }; }
```

# modules/home-manager/cli/zoxide/default.nix

```nix
{ lib, config, pkgs, ... }: let cfg = config.cli.zoxide; in { options.cli.zoxide.enable = lib.mkEnableOption "zoxide"; config = lib.mkIf cfg.enable { programs.zoxide = { enable = true; enableZshIntegration = true; }; }; }
```

# modules/home-manager/cli/zsh/default.nix

```nix
{ lib, config, pkgs, ... }: let cfg = config.cli.zsh; in { options.cli.zsh.enable = lib.mkEnableOption "zsh"; config = lib.mkIf cfg.enable { programs.zsh = { enable = true; zplug = { enable = true; plugins = [ { name = "zsh-users/zsh-autosuggestions"; } { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } ]; }; }; }; }
```

# modules/home-manager/default.nix

```nix
{ imports = [ ./cli ./gui ./services ]; }
```

# modules/home-manager/gui/cursor/default.nix

```nix
{ config, lib, pkgs, ... }: { options.gui.cursor.enable = lib.mkEnableOption "cursor"; config = lib.mkIf config.gui.cursor.enable { home.packages = with pkgs; [ code-cursor ]; }; }
```

# modules/home-manager/gui/default.nix

```nix
{ imports = [ ./hyprland ./stylix ./kitty ./cursor ./mako ./waybar ./wofi ]; }
```

# modules/home-manager/gui/hyprland/default.nix

```nix
{ lib, config, inputs,pkgs, ... }: let cfg = config.gui.hyprland; in { options.gui.hyprland.enable = lib.mkEnableOption "hyprland"; config = lib.mkIf cfg.enable { wayland.windowManager.hyprland = { enable = true; settings = { exec-once = [ "waybar" ]; general = { "$mod" = "SUPER"; gaps_in = 8; gaps_out = 16; border_size = 0; layout = "dwindle"; allow_tearing = true; monitor = [ ",preferred,auto,auto" "eDP-1,1920x1200@60,auto,1" ]; }; decoration = { rounding = 8; }; input = { kb_layout = "us"; follow_mouse = true; touchpad = { natural_scroll = true; }; accel_profile = "flat"; sensitivity = 0; }; bind = [ "$mod SHIFT,Return,exec,wofi --drun" "$mod,Return,exec,kitty" "$mod,Q,killactive," "$mod SHIFT,I,togglesplit," "$mod,F,fullscreen," "$mod SHIFT,F,togglefloating," "$mod ALT,F,workspaceopt, allfloat" "$mod SHIFT,C,exit," "$mod SHIFT,left,movewindow,l" "$mod SHIFT,right,movewindow,r" "$mod SHIFT,up,movewindow,u" "$mod SHIFT,down,movewindow,d" "$mod SHIFT,h,movewindow,l" "$mod SHIFT,l,movewindow,r" "$mod SHIFT,k,movewindow,u" "$mod SHIFT,j,movewindow,d" "$mod ALT, left, swapwindow,l" "$mod ALT, right, swapwindow,r" "$mod ALT, up, swapwindow,u" "$mod ALT, down, swapwindow,d" "$mod ALT, 43, swapwindow,l" "$mod ALT, 46, swapwindow,r" "$mod ALT, 45, swapwindow,u" "$mod ALT, 44, swapwindow,d" "$mod,left,movefocus,l" "$mod,right,movefocus,r" "$mod,up,movefocus,u" "$mod,down,movefocus,d" "$mod,h,movefocus,l" "$mod,l,movefocus,r" "$mod,k,movefocus,u" "$mod,j,movefocus,d" "$mod,1,workspace,1" "$mod,2,workspace,2" "$mod,3,workspace,3" "$mod,4,workspace,4" "$mod,5,workspace,5" "$mod,6,workspace,6" "$mod,7,workspace,7" "$mod,8,workspace,8" "$mod,9,workspace,9" "$mod,0,workspace,10" "$mod SHIFT,SPACE,movetoworkspace,special" "$mod,SPACE,togglespecialworkspace" "$mod SHIFT,1,movetoworkspace,1" "$mod SHIFT,2,movetoworkspace,2" "$mod SHIFT,3,movetoworkspace,3" "$mod SHIFT,4,movetoworkspace,4" "$mod SHIFT,5,movetoworkspace,5" "$mod SHIFT,6,movetoworkspace,6" "$mod SHIFT,7,movetoworkspace,7" "$mod SHIFT,8,movetoworkspace,8" "$mod SHIFT,9,movetoworkspace,9" "$mod SHIFT,0,movetoworkspace,10" "$mod CONTROL,right,workspace,e+1" "$mod CONTROL,left,workspace,e-1" "$mod,mouse_down,workspace, e+1" "$mod,mouse_up,workspace, e-1" "ALT,Tab,cyclenext" "ALT,Tab,bringactivetotop" ]; bindm = [ "$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow" ]; cursor = { sync_gsettings_theme = true; no_hardware_cursors = 2; enable_hyprcursor = false; warp_on_change_workspace = 2; no_warps = true; }; animations = { enabled = true; }; windowrule = [ "opacity 0.8 0.4, class:kitty" ]; env = [ "NIXOS_OZONE_WL, 1" "NIXPKGS_ALLOW_UNFREE, 1" "XDG_CURRENT_DESKTOP, Hyprland" "XDG_SESSION_TYPE, wayland" "XDG_SESSION_DESKTOP, Hyprland" "GDK_BACKEND, wayland, x11" "CLUTTER_BACKEND, wayland" "QT_QPA_PLATFORM=wayland;xcb" "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1" "QT_AUTO_SCREEN_SCALE_FACTOR, 1" "SDL_VIDEODRIVER, x11" "MOZ_ENABLE_WAYLAND, 1" # Disabling this by default as it can result in inop cfg # Added card2 in case this gets enabled. For better coverage # This is mostly needed by Hybrid laptops. #"AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1:/dev/card2" "GDK_SCALE,1" "QT_SCALE_FACTOR,1" "EDITOR,nvim" ]; }; }; }; }
```

# modules/home-manager/gui/kitty/default.nix

```nix
{ lib, config, pkgs, ... }: let cfg = config.gui.kitty; in { options.gui.kitty.enable = lib.mkEnableOption "kitty"; config = lib.mkIf cfg.enable { programs.kitty = { enable = true; settings = { confirm_os_window_close = 0; dynamic_background_opacity = true; enable_audio_bell = false; mouse_hide_wait = "-1.0"; window_padding_width = "10"; }; }; }; }
```

# modules/home-manager/gui/mako/default.nix

```nix
{ lib, config, pkgs, ... }: let cfg = config.gui.mako; in { options.gui.mako.enable = lib.mkEnableOption "mako"; config = lib.mkIf cfg.enable { services.mako = { enable = true; }; }; }
```

# modules/home-manager/gui/stylix/default.nix

```nix
{ lib, config, inputs, pkgs, ... }: let cfg = config.gui.stylix; in { imports = [ inputs.stylix.homeModules.stylix ]; options.gui.stylix.enable = lib.mkEnableOption "stylix"; config = lib.mkIf cfg.enable { stylix = { enable = true; base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml"; image = pkgs.fetchurl { url = "https://raw.githubusercontent.com/ek01992/wal/refs/heads/main/qhj152f5dc3f1.jpeg"; sha256 = "32d1e9307e1745bf55227135b9c6a16cff63115571edbd58eb3bd2df7a6700be"; }; cursor = { package = pkgs.bibata-cursors; name = "Bibata-Modern-Classic"; size = 24; }; fonts = { monospace = { package = pkgs.nerd-fonts.jetbrains-mono; name = "JetBrainsMono Nerd Font Mono"; }; emoji = { package = pkgs.noto-fonts-emoji; name = "Noto Color Emoji"; }; }; targets = { kitty.enable = true; gtk.enable = true; hyprland = { enable = true; hyprpaper.enable = true; }; waybar.enable = true; }; }; }; }
```

# modules/home-manager/gui/waybar/default.nix

```nix
{ lib, config, pkgs, ... }: let cfg = config.gui.waybar; in { options.gui.waybar.enable = lib.mkEnableOption "waybar"; config = lib.mkIf cfg.enable { programs.waybar = { enable = true; package = pkgs.waybar; settings = { }; }; home.packages = with pkgs; [ pavucontrol ]; }; }
```

# modules/home-manager/gui/wofi/default.nix

```nix
{ lib, config, pkgs, ... }: let cfg = config.gui.wofi; in { options.gui.wofi.enable = lib.mkEnableOption "wofi"; config = lib.mkIf cfg.enable { programs.wofi = { enable = true; settings = { }; }; }; }
```

# modules/home-manager/services/default.nix

```nix
{ imports = [ ]; }
```

# modules/nixos/core/default.nix

```nix
{ lib, config, pkgs, ... }: let cfg = config.nixos.core; in { options.nixos.core.enable = lib.mkEnableOption "core system settings"; config = lib.mkIf cfg.enable { nix.settings.experimental-features = [ "nix-command" "flakes" ]; time.timeZone = "America/Chicago"; i18n.defaultLocale = "en_US.UTF-8"; nixpkgs.config.allowUnfree = true; security.rtkit.enable = true; services.pipewire = { enable = true; alsa.enable = true; alsa.support32Bit = true; pulse.enable = true; jack.enable = true; }; fonts = { packages = with pkgs; [ font-awesome material-icons ]; }; environment.systemPackages = with pkgs; [ git curl wget alsa-ucm-conf pavucontrol eza bat coreutils direnv dnsutils nmap whois unzip fastfetch jq tcpdump zoxide fzf ripgrep libnotify mako yazi ]; }; }
```

# modules/nixos/default.nix

```nix
{ imports = [ ./core ./home-manager ./ssh ./hyprland ./zsh ./greetd ./obsidian ./nixvim ./power-management ]; }
```

# modules/nixos/greetd/default.nix

```nix
{ lib, config, pkgs, ... }: let cfg = config.nixos.greetd; in { options.nixos.greetd = { enable = lib.mkEnableOption "greetd"; # This 'user' option is what's missing from your current file. user = lib.mkOption { type = lib.types.str; default = "erik"; # Setting a default is good practice description = "The user to log in automatically with greetd."; }; }; config = lib.mkIf cfg.enable { services.greetd = { enable = true; settings = rec { initial_session = { command = "${pkgs.hyprland}/bin/Hyprland"; user = cfg.user; # This line can now find the option }; default_session = initial_session; }; }; }; }
```

# modules/nixos/home-manager/default.nix

```nix
{ lib, config, inputs, ... }: let cfg = config.nixos.home-manager; in { imports = [ inputs.home-manager.nixosModules.home-manager ]; options.nixos.home-manager.enable = lib.mkEnableOption "home-manager"; config = lib.mkIf cfg.enable { home-manager = { useGlobalPkgs = true; useUserPackages = true; backupFileExtension = "backup"; extraSpecialArgs = { inherit inputs; }; }; nixpkgs.overlays = [ inputs.nur.overlays.default ]; }; }
```

# modules/nixos/hyprland/default.nix

```nix
{ lib, config, inputs, pkgs, ... }: let cfg = config.nixos.hyprland; in { imports = [ inputs.home-manager.nixosModules.home-manager ]; options.nixos.hyprland.enable = lib.mkEnableOption "hyprland"; config = lib.mkIf cfg.enable { programs.hyprland = { enable = true; package = inputs.hyprland.packages.${pkgs.system}.hyprland; portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland; xwayland.enable = true; }; xdg.portal.enable = true; xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; }; }
```

# modules/nixos/nixvim/default.nix

```nix
{ lib, config, pkgs, inputs, ... }: let cfg = config.nixos.nixvim; in { imports = [ inputs.nixvim.nixosModules.nixvim ]; options.nixos.nixvim.enable = lib.mkEnableOption "nixvim"; config = lib.mkIf cfg.enable { programs.nixvim = { enable = true; defaultEditor = true; plugins = { lsp.enable = true; treesitter.enable = true; telescope.enable = true; lualine.enable = true; web-devicons.enable = true; }; opts = { number = true; relativenumber = true; hlsearch = true; }; keymaps = [ { key = "<leader>ff"; action = "<cmd>Telescope find_files<cr>"; options.desc = "Find Files"; } ]; }; }; }
```

# modules/nixos/obsidian/default.nix

```nix
{ config, lib, pkgs, ... }: { options.nixos.obsidian.enable = lib.mkEnableOption "obsidian"; config = lib.mkIf config.nixos.obsidian.enable { environment.systemPackages = with pkgs; [ obsidian ]; }; }
```

# modules/nixos/power-management/default.nix

```nix
{ lib, config, pkgs, ... }: let cfg = config.nixos.power-management; in { options.nixos.power-management.enable = lib.mkEnableOption "power management settings for laptops"; config = lib.mkIf cfg.enable { services.tlp = { enable = true; settings = { CPU_SCALING_GOVERNOR_ON_AC = "performance"; CPU_SCALING_GOVERNOR_ON_BAT = "powersave"; CPU_ENERGY_PERF_POLICY_ON_AC = "performance"; CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power"; CPU_BOOST_ON_AC = 1; CPU_BOOST_ON_BAT = 0; CPU_HWP_DYN_BOOST_ON_AC = 1; CPU_HWP_DYN_BOOST_ON_BAT = 0; PLATFORM_PROFILE_ON_AC = "performance"; PLATFORM_PROFILE_ON_BAT = "low-power"; }; }; services.thermald.enable = true; services.power-profiles-daemon.enable = false; powerManagement.powertop.enable = true; }; }
```

# modules/nixos/ssh/default.nix

```nix
{ lib, config, ... }: let cfg = config.nixos.ssh; in { options.nixos.ssh.enable = lib.mkEnableOption "openssh server"; config = lib.mkIf cfg.enable { services.openssh = { enable = true; settings = { PasswordAuthentication = false; PermitRootLogin = "no"; }; }; }; }
```

# modules/nixos/zsh/default.nix

```nix
{ lib, config, ... }: let cfg = config.nixos.zsh; in { options.nixos.zsh.enable = lib.mkEnableOption "zsh"; config = lib.mkIf cfg.enable { programs.zsh = { enable = true; enableCompletion = true; autosuggestions.enable = true; syntaxHighlighting.enable = true; shellAliases = { c = "clear"; cd = "z"; reboot = "sudo reboot now"; shutdown = "sudo shutdown now"; mkdir = "mkdir -vp"; rm = "rm -rifv"; mv = "mv -iv"; cp = "cp -riv"; cat = "bat --paging=never --style=plain"; ls = "eza -a --icons"; tree = "eza --tree --icons"; # nd = "nix develop -c $SHELL"; rebuild = "sudo nixos-rebuild switch"; upgrade = "sudo nixos-rebuild switch --upgrade"; }; }; }; }
```

# users/erik/default.nix

```nix
{ pkgs, ... }: { users.users = { erik = { initialPassword = "temp"; shell = pkgs.zsh; extraGroups = [ "wheel" "audio" "video" "networkmanager" ]; openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPakom6FvoSpBc0nmunHQUZwQI9VtS52i4W4WLuiUMpc ek01992@proton.me" ]; }; root = { extraGroups = [ "wheel" ]; }; }; }
```

# users/erik/home.nix

```nix
{ pkgs, inputs, config, ... }: { imports = [ inputs.self.homeModules.default ]; home.stateVersion = "25.05"; cli = { git = { enable = true; userName = "ek01992"; userEmail = "ek01992@proton.me"; }; zsh.enable = true; zoxide.enable = true; }; gui = { hyprland.enable = true; stylix.enable = true; kitty.enable = true; cursor.enable = true; mako.enable = true; waybar.enable = true; wofi.enable = true; }; services = { # TODO: Add services here }; }
```

