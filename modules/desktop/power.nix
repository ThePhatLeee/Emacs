{ config, lib, pkgs, ... }:

{
  # Disable conflicting power management
  services.power-profiles-daemon.enable = false;

  # Core power management
  services = {
    # Essential power monitoring
    upower = {
      enable = true;
      percentageLow = 15;
      percentageCritical = 5;
      percentageAction = 3;
      criticalPowerAction = "Hibernate";
    };

    # TLP for battery optimization
    tlp = {
      enable = true;
      settings = {
        # CPU management
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        # AMD Ryzen optimizations
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        # Basic power saving
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";

        # USB autosuspend
        USB_AUTOSUSPEND = 1;

        # NVMe power management
        DISK_DEVICES = "nvme0n1";
        DISK_APM_LEVEL_ON_BAT = "128";
      };
    };

    # Thermal management
    thermald.enable = true;
    services.fstrim.enable = true; # Crucial for NVMe SSD health
    hardware.sensor.iio.enable = true;

    # Memory Optimization (ZRAM)
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
      priority = 100;
    };
    
   services.udev.extraRules = ''
      ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
      ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/read_ahead_kb}="2048"
    '';
 


    # Firmware updates
    fwupd.enable = true;
  };

  # Essential tools
  environment.systemPackages = with pkgs; [
    powertop
    acpi
    lm_sensors
  ];

  # AMD-specific kernel parameter
  boot.kernelParams = [ "amd_pstate=active" ];

  # Basic power management
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
    # Intel Graphics & Media Acceleration
    hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      libvdpau-va-gl
      libva-vdpau-driver
    ];
  };


  # AMD microcode
  hardware.cpu.amd.updateMicrocode = true;
}
