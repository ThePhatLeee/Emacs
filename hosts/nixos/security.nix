
# hosts/nixos/security.nix
# Host-specific security configuration for Dell XPS 15 9510

{ config, pkgs, lib, ... }:

{
  # === TPM2 ===
  
  security.tpm2.enable = true;
  security.protectKernelImage = true;
  
  # === APPARMOR ===
  
  security.apparmor = {
    enable = true;
    packages = with pkgs; [
      apparmor-profiles
      apparmor-utils
    ];
    killUnconfinedConfinables = true;
  };

 # === USBGUARD ===
  # Protect against malicious USB devices (BadUSB, etc.)
  
  services.usbguard = {
    enable = true;
    
    # Allow by default during initial setup
    implicitPolicyTarget = "allow";
    
    # Allow users in wheel group to authorize devices
    IPCAllowedUsers = [ "root" "phatle" ];
    IPCAllowedGroups = [ "wheel" ];
    
    rules = ''
      # USB Hubs (Core)
      allow id 1d6b:0002
      allow id 1d6b:0003
      
      # Internal Hardware
      allow id 27c6:63ac
      allow id 0c45:6a11
      allow id 8087:0026
      
      # Dell WD19 Dock
      allow id 1d5c:5500
      allow id 1d5c:5510
      allow id 0bda:8153
      allow id 413c:c010
    '';
  };  
  # === FINGERPRINT READER ===
  
  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };
  
    # Enable fingerprint auth for sudo and login
  # Use mkForce to override display manager defaults
  security.pam.services = {
    login.fprintAuth = lib.mkForce true;
    sudo.fprintAuth = lib.mkForce true;
    polkit-1.fprintAuth = lib.mkForce true;
  };  
  # === ADDITIONAL SECURITY PACKAGES ===
  
  environment.systemPackages = with pkgs; [
    sbctl          # Secure Boot key management
    tpm2-tools     # TPM2 management
    cryptsetup     # LUKS management
    usbguard       # USB device management
  ];
}

