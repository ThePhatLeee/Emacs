# modules/desktop/power.nix
# Power management and optimization for desktop/laptop systems

{ config, lib, pkgs, ... }:

{
  # === DISABLE CONFLICTING SERVICES ===
  
  services.power-profiles-daemon.enable = false;

  # === CORE POWER MANAGEMENT ===
  
  services = {
    # Battery monitoring
    upower = {
      enable = true;
      percentageLow = 15;
      percentageCritical = 5;
      percentageAction = 3;
      criticalPowerAction = "Hibernate";
    };

    # TLP for advanced power management
    tlp = {
      enable = true;
      settings = {
        # CPU management
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        # Energy performance policy
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        
        # CPU boost
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        
        # Platform profiles
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";

        # WiFi power saving
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";

        # USB autosuspend
        USB_AUTOSUSPEND = 1;

        # NVMe power management
        DISK_DEVICES = "nvme0n1";
        DISK_APM_LEVEL_ON_BAT = "128";
        
        # Runtime power management
        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";
        
        # PCIe ASPM
        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersupersave";
        
        # Sound power save
        SOUND_POWER_SAVE_ON_AC = 0;
        SOUND_POWER_SAVE_ON_BAT = 1;
      };
    };

    # Firmware updates
    fwupd. enable = true;
    
    # Thermal management
    thermald.enable = true;
    
    # SSD TRIM
    fstrim.enable = true;
  };

  # === POWER MANAGEMENT ===
  
  powerManagement = {
    enable = true;
    powertop. enable = true;
  };

  # === ESSENTIAL TOOLS ===
  
  environment. systemPackages = with pkgs; [
    powertop
    acpi
    lm_sensors
    intel-gpu-tools
  ];

  # === CPU-SPECIFIC KERNEL PARAMETERS ===
  # Both AMD and Intel params - kernel uses appropriate one
  
  boot.kernelParams = [ 
    "amd_pstate=active"    # For AMD (ignored on Intel)
    # intel_pstate already in boot.nix
  ];
  
  # === INTEL GRAPHICS ===
  # Ignored on AMD systems
  
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      libvdpau-va-gl
      libva-vdpau-driver
    ];
  };
  
  # === ZRAM SWAP ===
  # Compressed swap in RAM (much faster than disk)
  
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;  # Higher priority than disk swap
  };

  # === CPU MICROCODE ===
  # Both enabled - only applicable one loads
  
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  
  # === IIO SENSOR SUPPORT ===
  # Accelerometer, etc.
  
  hardware.sensor.iio.enable = true;

  # === NVME OPTIMIZATIONS ===
  
  services.udev.extraRules = ''
    # NVMe:  use none scheduler (it has its own queue management)
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/read_ahead_kb}="2048"
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/nr_requests}="1024"
    
    # NVMe power management
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{power/control}="auto"
  '';
  
  # === MEMORY MANAGEMENT ===
  
  boot.kernel.sysctl = {
    # Swap behavior (prefer zram)
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    
    # Dirty memory ratios
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
    
    # Optimize for desktop
    "vm.page-cluster" = 0;
  };
}
