{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    steam
    heroic
    lutris
  ];
}
