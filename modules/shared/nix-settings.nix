# modules/shared/nix-settings. nix
# Nix daemon and build system configuration

{ lib, config, pkgs, ...  }:

{
  nix.settings = {
    # === CORE FEATURES ===
    
    experimental-features = [
      "nix-command"
      "flakes"
      "ca-derivations"
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
    stalled-download-timeout = 60;

    # === BINARY CACHES ===
    
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    # === CACHE OPTIMIZATION ===
    
    narinfo-cache-positive-ttl = 604800;  # Cache successful lookups for 1 week
    narinfo-cache-negative-ttl = 3600;    # Cache failures for 1 hour
    
    # === DISK SPACE MANAGEMENT ===
    
    min-free = "${toString (5 * 1024 * 1024 * 1024)}";   # Keep 5GB free
    max-free = "${toString (10 * 1024 * 1024 * 1024)}";  # Clean to 10GB if exceeded

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

  nix.daemonIOSchedClass = "idle";      # I/O scheduling
  nix.daemonCPUSchedPolicy = "batch";   # CPU scheduling
  
  systemd.services.nix-daemon. serviceConfig = {
    Nice = lib.mkDefault 10;
    IOSchedulingClass = lib.mkDefault "idle";
  };
  # === NIXPKGS CONFIG ===
  
  nixpkgs.config.allowUnfree = true;

  # === BOOT ENTRY LIMIT ===
  
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 10;
  
  # === JOURNAL OPTIMIZATION ===
  
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    SystemMaxFileSize=50M
    MaxRetentionSec=7day
    Compress=yes
    ForwardToSyslog=no
    ForwardToKMsg=no
    Storage=persistent          # Keep logs across reboots
    SyncIntervalSec=5m          # Sync every 5 min (reduces disk writes)
    RateLimitIntervalSec=30s    # Rate limit burst messages
    RateLimitBurst=10000        # Allow bursts up to 10k messages
  '';

  # === BUILD REPRODUCIBILITY TRACKING === (NEW)
  # Track what configuration was deployed
  
  system.activationScripts.buildManifest = ''
    mkdir -p /etc/nixos-build
    
    cat > /etc/nixos-build/manifest << EOF
    Build Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
    Hostname: ${config.networking.hostName}
    NixOS Release: ${config.system.nixos.release}
    NixOS Version: ${config.system.nixos.version}
    Kernel: ${config.boot.kernelPackages.kernel.version}
    Configuration Path: /home/phatle/Emacs
    Git Commit: $(cd /home/phatle/Emacs 2>/dev/null && git rev-parse HEAD 2>/dev/null || echo "unknown")
    Git Branch: $(cd /home/phatle/Emacs 2>/dev/null && git branch --show-current 2>/dev/null || echo "unknown")
    Git Status: $(cd /home/phatle/Emacs 2>/dev/null && (git diff-index --quiet HEAD -- && echo "clean" || echo "DIRTY") 2>/dev/null || echo "unknown")
    EOF
    
    chmod 644 /etc/nixos-build/manifest
  '';
  
  # Add command to check build info (NEW)
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "nixos-build-info" ''
      if [ -f /etc/nixos-build/manifest ]; then
        cat /etc/nixos-build/manifest
      else
        echo "No build manifest found.  Run 'sudo nixos-rebuild switch' to generate."
      fi
    '')
  ];
}
