# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  sources = import ./lon.nix;
  lanzaboote = import sources.lanzaboote { inherit pkgs; };
in


{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./security.nix
    ../../profiles/workstation.nix
  ];
  
  # === HARDWARE-SPECIFIC CONFIGURATION ===
  
  networking. hostName = "nixos";
  
  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # Override LUKS device UUID from boot.nix default
  # This is the ONLY thing hardware-specific about boot config
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/0ebd4574-226c-4520-b4ad-5713d80f03fd";
    allowDiscards = true;
    bypassWorkqueues = true;
    crypttabExtraOpts = [ 
      "tpm2-device=auto"
      "tpm2-pcrs=0+2+7+12"  # PCR 0+2+7+15 configuration
    ];
  };
  
  # Swap subvolume configuration (Btrfs-specific)
  fileSystems."/swap" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=@swap" "noatime" "nodatacow" ];
  };
  
  swapDevices = [ { 
    device = "/swap/swapfile"; 
    priority = 0;  # Lower priority than zram (from power.nix)
  } ];
  
  # === USER CONFIGURATION ===
  
  users.users.phatle = {
    isNormalUser = true;
    description = "Marko Jokinen";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    
    # Generate with:  mkpasswd -m sha-512
    # REPLACE THIS BEFORE DEPLOYING: 
    hashedPassword = "$6$VSPG.ukJ4Y4XZgjP$JZTMArVVegzqRUNxFNL0bSAcGJslb.ri9naoO409.OR832F0X4dkDHwtc2EkYb75N14w/zOITPJiMxj1DBixX0";
    
    packages = with pkgs; [
      git
    ];
  };
  
  # === SYSTEM STATE ===
  
  system. stateVersion = "25.11";
}

