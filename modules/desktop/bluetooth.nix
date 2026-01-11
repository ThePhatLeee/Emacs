{ config, pkgs, ... }:
{
  # Enable Bluetooth
  
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        ControllerMode = "dual";
        FastConnectable = "true";
      };
      Policy = {
        AutoEnable = "true";
      };
    };
  };
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    bluez
    bluetui
    blueman
    bluez-tools
  ];
}
