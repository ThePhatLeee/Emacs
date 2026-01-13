{ config, pkgs, ... }:
{
  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Enable firmware
  hardware.enableAllFirmware = true;
  # Enable ALL firmware including proprietary
  hardware.enableRedistributableFirmware = true;


  # Packages
  environment.systemPackages = with pkgs; [
    networkmanager
    networkmanagerapplet
  ];
}
