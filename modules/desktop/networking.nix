# modules/desktop/networking.nix
# Network configuration and hardening for desktop systems

{ config, pkgs, lib, ... }: 

{
  # === NETWORK MANAGER ===
  
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";  # Use systemd-resolved for DNS
    
    settings = {
      # WiFi privacy
      device."wifi.scan-rand-mac-address" = "yes";
      
      # MAC address randomization
      connection = {
        "ipv6.ip-token" = "stable-privacy";
        "ethernet.cloned-mac-address" = "random";
        "wifi.cloned-mac-address" = "random"; 
      };
    };
  };

  # === FIREWALL ===
  
  networking.firewall = {
    enable = true;
    allowPing = false;
    checkReversePath = "strict";
    trustedInterfaces = [ "lo" "proton0" ];
    logRefusedConnections = true;
    logRefusedPackets = false;  # Too verbose
  };

  # === KERNEL NETWORK HARDENING ===
  
  boot.kernel.sysctl = {
    # Performance
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";

    # === TCP PERFORMANCE TUNING === 
    # 10x improvement on fast networks
    "net.core.rmem_max" = 134217728;           # 128MB receive buffer
    "net.core.wmem_max" = 134217728;           # 128MB send buffer
    "net.ipv4.tcp_rmem" = "4096 87380 67108864";  # Min, default, max read
    "net.ipv4.tcp_wmem" = "4096 65536 67108864";  # Min, default, max write
    
    # TCP Fast Open (reduces latency by 1 RTT)
    "net.ipv4.tcp_fastopen" = 3;  # Enable for both client and server
    
    # Connection reuse (faster reconnections)
    "net.ipv4.tcp_tw_reuse" = 1;
    
    # Increase connection backlog
    "net.core.netdev_max_backlog" = 16384;
    "net.ipv4.tcp_max_syn_backlog" = 8192;
    
    # IPv6 privacy extensions
    "net.ipv6.conf.all.use_tempaddr" = lib.mkForce 2;
    "net.ipv6.conf.default.use_tempaddr" = lib.mkForce 2;
    
    # IP forwarding (disabled)
    "net.ipv4.ip_forward" = 0;
    "net.ipv6.conf.all.forwarding" = 0;
    
    # ICMP security
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    
    # Redirect protection
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    
    # Source routing (disabled)
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;
    
    # Reverse path filtering
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    
    # Log martians
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.default.log_martians" = 1;
    
    # TCP hardening
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.tcp_rfc1337" = 1;
    "net.ipv4.tcp_timestamps" = 1;
    
    # Disable autogroup scheduling (better for desktop)
    "kernel.sched_autogroup_enabled" = 0;
  };

  # === DNS PRIVACY WITH DNS OVER TLS ===
  # Encrypted DNS queries via systemd-resolved
  
 
services.resolved = {
  enable = true;
  dnssec = "false"; 
  dnsovertls = "opportunistic"; 
  fallbackDns = [
    "1.1.1.1#one.one.one.one"
    "1.0.0.1#one.one.one.one"
    "2606:4700:4700::1111#one.one.one.one"
    "2606:4700:4700::1001#one.one.one.one"
  ];

  settings = {
    Resolve = {
      DNSStubListener = "yes"; 
      DNSStubListenerExtra = "127.0.0.53";
      Cache = "yes";
      MulticastDNS = "no";
      LLMNR = "no";
      DNS = [ "..." ]; 
    };
  };
};# === PACKAGES ===
  
  environment.systemPackages = with pkgs; [
    networkmanager
    networkmanagerapplet
  ];

  networking.extraHosts = ''
  '';
}
