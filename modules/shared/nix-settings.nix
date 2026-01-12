# modules/shared/nix-settings. nix
# Nix daemon and build system configuration

{ lib, config, ...  }:

{
  nix. settings = {
    # === CORE FEATURES ===
    
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    
    trusted-users = [
      "root"
      "phatle"
    ];

    # === STORE OPTIMIZATION ===
    
    auto-optimise-store = true;
    max-jobs = "auto";

    # === BUILD OPTIMIZATION ===
    
    cores = 0;  # Use all CPU cores
    sandbox = true;
    
    # Build performance
    builders-use-substitutes = true;
    keep-outputs = true;
    keep-derivations = true;
    keep-failed = false;  # Don't keep failed builds
    
    # Log compression
    compress-build-log = true;
    
    # Download optimizations
    http-connections = 50;
    download-attempts = 5;
    connect-timeout = 5;

    # === BINARY CACHES ===
    
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    # === CONVENIENCE ===
    
    warn-dirty = false;  # Don't warn about dirty git repos
  };

  # === GARBAGE COLLECTION ===
  
  nix.gc = lib.mkDefault {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # === STORE OPTIMIZATION ===
  
  nix.optimise = {
    automatic = true;
    dates = [ "03:45" ];  # 3:45 AM
  };
  
  # === NIX DAEMON PRIORITY ===
  # Don't let builds slow down interactive work
  
  systemd.services.nix-daemon. serviceConfig = {
    Nice = lib.mkDefault 10;
    IOSchedulingClass = lib. mkDefault "idle";
  };
  # === NIXPKGS CONFIG ===
  
  nixpkgs.config. allowUnfree = true;

  # === BOOT ENTRY LIMIT ===
  
  boot. loader.systemd-boot.configurationLimit = lib.mkDefault 10;
  
  # === JOURNAL OPTIMIZATION ===
  
  services. journald.extraConfig = ''
    SystemMaxUse=500M
    SystemMaxFileSize=50M
    MaxRetentionSec=7day
    Compress=yes
    ForwardToSyslog=no
    ForwardToKMsg=no
  '';
}
