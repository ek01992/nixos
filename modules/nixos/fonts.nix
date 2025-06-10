{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    nerd-fonts.fire-code
    nerd-fonts.droid-sans-mono
  ];
}