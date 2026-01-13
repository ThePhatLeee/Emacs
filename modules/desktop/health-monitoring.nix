{ config, pkgs, lib, ... }: 
{
  # === DAILY SECURITY AUDIT ===
  
  systemd.services.security-audit = {
    description = "Daily Security Audit with Lynis";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      ${pkgs.lynis}/bin/lynis audit system --cronjob --quick > /var/log/lynis-daily.log 2>&1
      
      # Check for critical issues
      if grep -q "warning\[" /var/log/lynis-daily.log; then
        echo "⚠️ Security warnings found.  Check:  /var/log/lynis-daily.log"
      fi
    '';
  };
  
  systemd.timers.security-audit = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };
  
  # === WEEKLY BTRFS HEALTH CHECK ===
  
  systemd.services.btrfs-health = {
    description = "Weekly Btrfs Health Check";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      echo "=== Btrfs Health Check $(date) ===" > /var/log/btrfs-health.log
      ${pkgs.btrfs-progs}/bin/btrfs device stats / >> /var/log/btrfs-health.log 2>&1
      ${pkgs.btrfs-progs}/bin/btrfs filesystem usage / >> /var/log/btrfs-health.log 2>&1
      
      # Alert on errors
      if ${pkgs.btrfs-progs}/bin/btrfs device stats / | grep -v " 0$"; then
        echo "⚠️ Btrfs device errors detected!  Check: /var/log/btrfs-health.log"
      fi
    '';
  };
  
  systemd.timers.btrfs-health = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };
  
  # === MONTHLY SMART DRIVE HEALTH CHECK ===
  
  systemd.services.smart-check = {
    description = "Monthly SMART Drive Health Check";
    serviceConfig. Type = "oneshot";
    script = ''
      ${pkgs.smartmontools}/bin/smartctl -a /dev/nvme0n1 > /var/log/smart-report.log 2>&1 || true
      
      if grep -qi "error" /var/log/smart-report.log; then
        echo "⚠️ SMART errors detected! Check: /var/log/smart-report.log"
      fi
    '';
  };
  
  systemd.timers.smart-check = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "monthly";
      Persistent = true;
    };
  };
}
