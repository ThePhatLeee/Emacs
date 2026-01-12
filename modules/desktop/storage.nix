# modules/desktop/storage.nix
# Storage and filesystem defaults for desktop systems

{ config, pkgs, lib, ... }: 

{
  # === USB STORAGE ===
  
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  systemd.services. udisks2 = {
    wantedBy = [ "graphical-session.target" ];
  };

  # === STORAGE PACKAGES ===
  
  environment.systemPackages = with pkgs; [
    # File manager integration
    gvfs
    udisks2

    # Disk management tools
    gnome-disk-utility
    gparted

    # Image writing tools
    kdePackages.isoimagewriter
    dd_rescue
    pv

    # Btrfs tools
    btrfs-progs
    compsize  # Check compression ratios
  ];
  
  # === BTRFS OPTIMIZATION DEFAULTS ===
  # Append optimized mount options to existing filesystem definitions
  # Uses lib.mkAfter to merge with hardware-configuration.nix settings
  
  # Root filesystem - append optimization options
  fileSystems. "/".options = lib.mkAfter [ 
    "noatime"              # Don't update access times (performance)
    "compress=zstd:1"      # Fast compression (level 1)
    "space_cache=v2"       # Better free space cache
    "discard=async"        # Async TRIM for SSDs
    "ssd"                  # SSD-specific optimizations
    "autodefrag"           # Auto-defragmentation for small files
  ];
  
  # Nix store - higher compression for space savings
  fileSystems."/nix".options = lib.mkAfter [ 
    "noatime"
    "compress=zstd:3"      # Higher compression level
    "space_cache=v2"
    "discard=async"
    "ssd"
  ];
  
  # Home directory
  fileSystems."/home". options = lib.mkAfter [ 
    "noatime"
    "compress=zstd:1"
    "space_cache=v2"
    "discard=async"
    "ssd"
    "autodefrag"
  ];
  
  # Boot partition - override to secure (use mkForce since this is security-critical)
  fileSystems."/boot".options = lib. mkForce [ 
    "fmask=0077"           # Only root can read/write files
    "dmask=0077"           # Only root can read/write directories
    "noatime"
  ];
  
  # === BTRFS MAINTENANCE ===
  
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };
}
