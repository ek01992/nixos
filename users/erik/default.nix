# users/erik/default.nix
{ pkgs, config, ... }:
{
  users.users = {
    erik = {
      initialPassword = "temp";
      shell = pkgs.zsh;
      extraGroups = [
        "wheel" "audio" "video" "networkmanager"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPakom6FvoSpBc0nmunHQUZwQI9VtS52i4W4WLuiUMpc ek01992@proton.me"
      ];
    };
    root = {
      extraGroups = [
        "wheel"
      ];
    };
  };
}