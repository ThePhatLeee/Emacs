{ lib, ... }:
{
  imports = [
    ../modules/cli-tui
    ../modules/development
    ../modules/desktop
    ../modules/media
    ../modules/security
    ../modules/shared
  ];

  time.timeZone = lib.mkDefault "Europe/Helsinki";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fi_FI.UTF-8";
    LC_IDENTIFICATION = "fi_FI.UTF-8";
    LC_MEASUREMENT = "fi_FI.UTF-8";
    LC_MONETARY = "fi_FI.UTF-8";
    LC_NAME = "fi_FI.UTF-8";
    LC_NUMERIC = "fi_FI.UTF-8";
    LC_PAPER = "fi_FI.UTF-8";
    LC_TELEPHONE = "fi_FI.UTF-8";
    LC_TIME = "fi_FI.UTF-8";
  };
  boot.loader.systemd-boot.configurationLimit = 20;

  # Optimizations
  nix = {
    # Auto-optimize store daily (deduplicates files)
    settings.auto-optimise-store = true;

    # Auto garbage-collect weekly
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d"; # Keep last 2 weeks of builds
    };
  };

  system.activationScripts.userAvatar = ''
      mkdir -p /var/lib/AccountsService/{icons,users}
      cp ${../assets/phatle.png} /var/lib/AccountsService/icons/phatle
      chmod 644 /var/lib/AccountsService/icons/phatle
      cat > /var/lib/AccountsService/users/phatle << 'EOF'
    [User]
    Icon=/var/lib/AccountsService/icons/phatle
    EOF
  '';
}
