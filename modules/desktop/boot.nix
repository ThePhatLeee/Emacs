# modules/desktop/boot.nix
# Boot configuration defaults for all desktop systems

{ config, lib, pkgs, ... }:

{
  # === PLYMOUTH BOOT SPLASH ===
  
  boot.plymouth = {
    enable = true;
    theme = "breeze";
  };

  # === KERNEL PARAMETERS ===
  # Security hardening and performance optimizations
  
  boot.kernelParams = [
    # Silent boot
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    
    # Security hardening
    "pti=on"                          # Meltdown/Spectre mitigation
    "slab_nomerge"                    # Prevent slab merging (security)
    "page_alloc.shuffle=1"            # Randomize page allocator
    "randomize_kstack_offset=on"      # Randomize kernel stack
    "init_on_alloc=1"                 # Zero memory on allocation
    "init_on_free=1"                  # Zero memory on free
    "vsyscall=none"                   # Disable vsyscall (security)
    "debugfs=off"                     # Disable debugfs (security)
    "lockdown=integrity"              # Kernel lockdown (CHANGED from confidentiality)
    
    # Performance
    "mem_sleep_default=deep"          # Deep sleep for better battery
    "pcie_aspm=force"                 # PCIe power saving
    "nvme_core.default_ps_max_latency_us=0"  # NVMe performance
    
    # Intel defaults (ignored on AMD)
    "intel_pstate=active"             # Intel P-state driver
    "i915.enable_psr=1"               # Panel Self Refresh
    "i915.enable_fbc=1"               # Frame buffer compression
    
    # Boot
    "boot.shell_on_fail"              # Emergency shell on boot failure
    "transparent_hugepage=madvise"    # THP only when requested (better performance)
    "mitigations=auto"                # Auto-enable only needed mitigations (performance)
  ];

  boot.consoleLogLevel = 0;
  
  # === BOOT LOADER ===
  # Lanzaboote for Secure Boot
  
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;  # Instant boot (no menu, hold space on boot to get boot loader)

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # GRUB theme (for systems that use GRUB instead)
  boot.loader.grub.theme = pkgs.nixos-grub2-theme;
  boot.loader.grub.configurationLimit = 5;

  # === INITRD CONFIGURATION ===
  
  boot.initrd = {
    # Use systemd in initrd (faster, more reliable)
    systemd.enable = true;
       
    # TPM kernel module
    kernelModules = [ "tpm_tis" ];
    
    # Silent initrd
    verbose = false;
    
    # Optimize initrd compression
    compressor = "zstd";
    compressorArgs = [ "-19" "-T0" ];  # Max compression, all threads
    
    # LUKS defaults
    # Hosts MUST override the device UUID with their specific value
    # This is just a fallback that will never be used
    luks.devices.cryptroot = lib.mkDefault {
      device = "/dev/disk/by-uuid/0ebd4574-226c-4520-b4ad-5713d80f03fd";  # Placeholder
      allowDiscards = true;
      bypassWorkqueues = true;
      crypttabExtraOpts = [ 
        "tpm2-device=auto" 
        "tpm2-pcrs=0+2+7+12"  # Default PCR configuration
      ];
    };
  };
  
  # === TMPFS FOR /tmp ===
  # Faster, reduces disk wear
  
  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "8G";  # Safe for 16GB+ RAM systems
    cleanOnBoot = true;
  };
  
  # === KERNEL SYSCTL HARDENING ===
  
  boot.kernel.sysctl = {
    # Kernel hardening
    "kernel.kexec_load_disabled" = 1;
    "kernel.unprivileged_bpf_disabled" = 1;
    "kernel.unprivileged_userns_clone" = 0;
    "kernel.yama.ptrace_scope" = 2;
    "kernel.kptr_restrict" = 2;
    
    # Filesystem protections
    "fs.protected_hardlinks" = 1;
    "fs.protected_symlinks" = 1;
    "fs.protected_regular" = 2;
    "fs.protected_fifos" = 2;
    "fs.suid_dumpable" = 0;
    
    # Increase inotify limits (for development) remove if build fails
    "fs.inotify.max_user_watches" = 524288;   # Default is 8192 (64x increase)
    "fs.inotify.max_user_instances" = 512;    # Default is 128 (4x increase)
    "fs.inotify.max_queued_events" = 32768;   # Default is 16384 (2x increase)
  };
  
  # === KERNEL MODULE BLACKLIST ===
  # Disable unused/dangerous modules
  
  boot.blacklistedKernelModules = [
    # Unused filesystems
    "cramfs" "freevxfs" "jffs2" "hfs" "hfsplus" "squashfs" "udf"
    
    # Unused network protocols
    "dccp" "sctp" "rds" "tipc" "n-hdlc"
    "ax25" "netrom" "x25" "rose" "decnet" "econet"
    "af_802154" "ipx" "appletalk" "psnap" "p8023" "p8022"
    "can" "atm"
    
    # Unused hardware
    "firewire-core" "firewire-ohci" "firewire-sbp2"
    "pcspkr"  # PC speaker
  ];
  
  # === SYSTEMD OPTIMIZATIONS ===
  
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "30s";
    DefaultTimeoutStopSec = "15s";
  }
;}
