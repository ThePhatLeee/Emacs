{ config, lib, pkgs, ... }:

{
  # Fast, beautiful Plymouth boot with NixOS branding
  boot.plymouth = {
    enable = true;
    theme = "breeze";
  };

  # Silent boot for speed and clean look
  boot.kernelParams = [
    "quiet" "splash" "mem_sleep_default=deep" "pti=on" "slab_nomerge"
    "page_alloc.shuffle=1" "randomize_kstack_offset=on" "debugfs=off"
    "vsyscall=none" "lockdown=confidentiality" "pcie_aspm=force"
    "intel_pstate=active" "nvme_core.default_ps_max_latency_us=0"
    "i915.enable_psr=1" "i915.enable_fbc=1" "boot.shell_on_fail" 
    "loglevel=3" "rd.systemd.show_status=false" "rd.udev.log_level=3" "udev.log_priority=3"
  ];

   

  boot.consoleLogLevel = 0;
  
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Beautiful GRUB theme
  boot.loader.grub.theme = pkgs.nixos-grub2-theme;

  # Keep boot entries clean
  boot.loader.grub.configurationLimit = 5;

  # LUKS + Plymouth integration for themed password prompts
  
boot.initrd = {
    systemd.enable = true;
    kernelModules = [ "tpm_tis" ];
    verbose = false;
    luks.devices = {
        "cryptroot" = {
        device = "/dev/disk/by-uuid/0ebd4574-226c-4520-b4ad-5713d80f03fd";
        
        # These options MUST be inside this "cryptroot" block
        allowDiscards = true;
        bypassWorkqueues = true;
        crypttabExtraOpts = [ "tpm2-device=auto" "tpm2-measure-pcr=yes" ];
      };
      };
    };
}
