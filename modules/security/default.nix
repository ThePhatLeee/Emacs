# modules/security/default.nix
# Security hardening defaults for all systems

{ config, pkgs, lib, ... }:

let
  # DRY Principle: Define the umask rule once, apply it everywhere.
  # We use 'mkOrder' to ensure this runs after standard session setup but before user control.
  umaskRule = lib.mkOrder 200 {
    control = "optional";
    modulePath = "${pkgs.pam}/lib/security/pam_umask.so";
    args = [ "umask=0027" ];
  };
in

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
  
  # 1. SYSTEM LIMITS (DoS Protection)
  # Prevents fork bombs and resource exhaustion attacks.
  security.pam.loginLimits = [
    { domain = "*"; item = "nproc"; type = "hard"; value = "4096"; }
    { domain = "*"; item = "nofile"; type = "hard"; value = "524288"; }
    # PRO TIP: Lock memory limits for sensitive processes (like GPG/SSH agents) to prevent swapping keys to disk.
    { domain = "@wheel"; item = "memlock"; type = "hard"; value = "1048576"; }
  ];

  # 2. BRUTE FORCE PROTECTION (Faillock)
  # Standard PAM doesn't lock users out by default. This fixes that.
  security.pam.services.login.faillockConfig = {
    enable = true;
    deny = 5;             # Lock after 5 failed attempts
    unlock_time = 900;    # Lock for 15 minutes
    interval = 600;       # Reset counter if 10 mins pass without failure
  };
  
  # Inherit faillock config for SSHD to prevent online dictionary attacks
  security.pam.services.sshd.faillockConfig = config.security.pam.services.login.faillockConfig;

  # 3. PRIVILEGE ESCALATION BARRIERS
  # Only users in the 'wheel' group can even ATTEMPT to use 'su'.
  # This reduces the attack surface if a non-admin service account is compromised.
  security.pam.services.su.wheelOnly = true;

  # 4. UMASK APPLICATION (The Refactored Way)
  # Apply the rule defined in 'let' to critical entry points.
  security.pam.services.login.rules.session.umask = umaskRule;
  security.pam.services.sshd.rules.session.umask = umaskRule;
  # Also apply to graphical login (Greeter) if you use one (e.g., GDM, SDDM, greetd)
  # security.pam.services.greetd.rules.session.umask = umaskRule; 

  # 5. SUDO AUDITING
  # Your tmpfiles rule is good, but we need to tell sudo to actually WRITE there.
  security.sudo.extraConfig = ''
    Defaults logfile=/var/log/sudo.log
    Defaults log_year, log_host
  '';
  
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
