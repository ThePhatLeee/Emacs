{ pkgs, ...}:
{
  security.tpm2.enable = true;
  security.protectKernelImage = true;
  security.apparmor = {
    enable = true;
    packages = with pkgs; [
      apparmor-profiles
      apparmor-utils
    ];
  };


    services.usbguard = {
    enable = true;

    rules = ''
      # --- Core ---
      allow id 1d6b:0002 # Root Hub 2.0
      allow id 1d6b:0003 # Root Hub 3.0

      # --- Internal Hardware ---
      allow id 27c6:63ac # Fingerprint
      allow id 0c45:6a11 # Webcam
      allow id 8087:0026 # Intel AX201 Bluetooth

      # --- External Dock ---
      allow id 1d5c:5500 # Fresco Logic 3.0
      allow id 1d5c:5510 # Fresco Logic 2.0
      allow id 0bda:8153 # Ethernet
      allow id 413c:c010 # Composite
    '';
  };
    services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };






}
