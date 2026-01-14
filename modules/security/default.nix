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
 
  # === PAM HARDENING === (NEW)
  # Stricter file permissions and limits
  
  # 1. Login Limits (This part is correct and valid)
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "hard";
      item = "nproc";
      value = "4096";  # Limit processes per user
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "524288";  # Increase file descriptor limit
    }
  ];

  # 2. Umask (The syntax changed)
  # Corrected PAM Umask rules using absolute paths for AppArmor compatibility
  security.pam.services.login.rules.session.umask = {
    control = "optional";
    # CHANGED: Use full path from pkgs.pam
    modulePath = "${pkgs.pam}/lib/security/pam_umask.so"; 
    args = [ "umask=0027" ];
    order = 200;
  };

  security.pam.services.sshd.rules.session.umask = {
    control = "optional";
    # CHANGED: Use full path from pkgs.pam
    modulePath = "${pkgs.pam}/lib/security/pam_umask.so";
    args = [ "umask=0027" ];
    order = 200;
  };
  # 3. Sudo Log Permissions
  systemd.tmpfiles.rules = [
    "f /var/log/sudo.log 0600 root root - -"
  ];  

  # === POLKIT SECURITY === 
  # Require authentication for system operations
  
  security.polkit.enable = true;  # Already enabled in theming. nix, this ensures it
  security.polkit.extraConfig = ''
    /* Require authentication for system management */
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("org.freedesktop.systemd1.manage-units") == 0 ||
          action.id.indexOf("org.freedesktop.login1.power-off") == 0 ||
          action.id.indexOf("org.freedesktop.login1.reboot") == 0 ||
          action.id.indexOf("org.freedesktop.login1.suspend") == 0) {
        if (subject.isInGroup("wheel")) {
          return polkit.Result.AUTH_ADMIN_KEEP;
        }
        return polkit.Result.NO;
      }
    });
    
    /* Restrict mount operations */
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.udisks2.filesystem-mount-system") {
        if (subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
        return polkit.Result.AUTH_ADMIN;
      }
    });
    
    /* Restrict network device control */
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("org.freedesktop.NetworkManager.") == 0) {
        if (subject.isInGroup("wheel") || subject.isInGroup("networkmanager")) {
          return polkit.Result.YES;
        }
        return polkit.Result.AUTH_ADMIN;
      }
    });
  '';

  # === KERNEL IMAGE PROTECTION === (NEW)
  # Force PTI even if not auto-detected
  
  security.forcePageTableIsolation = true;



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
  
  networking.firewall. enable = true;

  # === SECURITY PACKAGES ===
  
  environment.systemPackages = with pkgs; [
    fail2ban
    gnupg
    age
    sbctl          # Secure Boot management
    tpm2-tools     # TPM management
    cryptsetup     # LUKS management
    lynis          # Security auditing
  ];
}
