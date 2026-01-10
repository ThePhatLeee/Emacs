{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Graphics must remain enabled for any desktop to work
  services.graphical-desktop = {
    enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Testing the specialist's "Open" recommendation
    open = true;
    nvidiaSettings = true;

    powerManagement = {
      enable = true;
      finegrained = true;
    };

    # Extra juice for the 3050 Ti when it IS active
    dynamicBoost.enable = true;

    # We are removing the explicit PRIME Bus IDs to see if
    # Plasma Wayland handles it automatically as suggested.
  };
}

