{ config, pkgs, lib, ... }:
{
  # Enable NetworkManager
 
  networking.networkmanager = {
    enable = true;
    settings = {
      device."wifi.scan-rand-mac-address" = "yes";
      connection = {
        "ipv6.ip-token" = "stable-privacy";
        "ethernet.cloned-mac-address" = "random";
        "wifi.cloned-mac-address" = "random";
      };
    };
  };

    networking.firewall = {
    enable = true;
    allowPing = false;
    checkReversePath = "strict";
    trustedInterfaces = [ "lo" ];
  };

  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv6.conf.all.use_tempaddr" = lib.mkForce 2;
    "net.ipv6.conf.default.use_tempaddr" = lib.mkForce 2;
    "kernel.sched_autogroup_enabled" = 0;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.tcp_syncookies" = 1;
    "kernel.dmesg_restrict" = 1;
  };


  # Packages
  environment.systemPackages = with pkgs; [
    networkmanager
    networkmanagerapplet
  ];

  networking.extraHosts = ''
  '';
}
