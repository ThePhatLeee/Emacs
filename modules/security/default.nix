# modules/security/default.nix
# Security hardening defaults for all systems

{ config, pkgs, lib, ... }: 

{
  imports = [
    ./keychain.nix
  ];

  # === SUDO HARDENING ===
  
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
    execWheelOnly = true;
    
    extraConfig = ''
      # Require password every time
      Defaults timestamp_timeout=0
      
      # Use PTY for isolation
      Defaults use_pty
      
      # Log all sudo commands
      Defaults logfile="/var/log/sudo.log"
      
      # Disable root password
      
      
      # Show lecture
      Defaults lecture="always"
    '';
  };

  # Emergency root access (for TPM unlock failures)
  users.users.root = {
    # Set a STRONG password for emergency mode only
    # Generate one with: mkpasswd -m sha-512
    hashedPassword = "$6$VSPG.ukJ4Y4XZgjP$JZTMArVVegzqRUNxFNL0bSAcGJslb.ri9naoO409.OR832F0X4dkDHwtc2EkYb75N14w/zOITPJiMxj1DBixX0";
  };
  
  # === AUDIT LOGGING ===
  # Track all security-relevant events
  
  security.auditd.enable = true;
  security.audit = {
    enable = true;
    #rules = [
      # Authentication monitoring
    #  "-w /var/log/faillog -p wa -k auth"
    #  "-w /var/log/lastlog -p wa -k auth"
      
      # Identity changes
    #  "-w /etc/passwd -p wa -k identity"
    #  "-w /etc/group -p wa -k identity"
    #  "-w /etc/shadow -p wa -k identity"
    #  "-w /etc/gshadow -p wa -k identity"
      
      # Sudo monitoring
    #  "-w /etc/sudoers -p wa -k sudoers"
    #  "-w /etc/sudoers. d/ -p wa -k sudoers"
      
      # System config
    #  "-w /etc/nixos/ -p wa -k nixos_config"
      
      # Kernel modules
    #  "-w /sbin/insmod -p x -k modules"
    #  "-w /sbin/modprobe -p x -k modules"
    #  "-w /sbin/rmmod -p x -k modules"
      
      # Time changes (fixed syntax)
    #  "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -S clock_settime -k time_change"
    #  "-w /etc/localtime -p wa -k time_change"
      
      # File deletions (fixed syntax)
    #  "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete"
      
      # Privilege escalation
    #  "-a always,exit -F arch=b64 -S setuid -F a0=0 -k privilege_escalation"
    #];
  };
  # === ADDITIONAL KERNEL HARDENING ===
  
  boot.kernelParams = [
    # Disable SYSRQ keys (prevent physical attack)
    "sysrq_always_enabled=0"
  ];
  
  boot.kernel.sysctl = {
    # Additional hardening
    "kernel.dmesg_restrict" = 1;
    "kernel.perf_event_paranoid" = 3;
    "net.core.bpf_jit_harden" = 2;
  };


  # === NETWORKING ===
  
  # Enable mosh
  programs.mosh.enable = true;

  # Tailscale
  

  # === SSH HARDENING ===
  
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      Protocol = 2;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
    };
    
    extraConfig = ''
      Match User phatle
        AllowAgentForwarding yes
    '';
  };
  
  # Fail2ban
  services.fail2ban = {
    enable = lib.mkDefault true;
    maxretry = 3;
    bantime = "1h";
  };

  # === FIREWALL ===
  
  networking. firewall. enable = true;

  # === SECURITY PACKAGES ===
  
  environment. systemPackages = with pkgs; [
    fail2ban
    gnupg
    age
    sbctl          # Secure Boot management
    tpm2-tools     # TPM management
    cryptsetup     # LUKS management
    lynis          # Security auditing
  ];
}
