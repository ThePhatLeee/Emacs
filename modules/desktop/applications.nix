{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # File managers
    xfce.thunar
    xfce.tumbler

    # Graphics and image optimizations
    gimp3-with-plugins
    inkscape
    darktable
    libwebp
    libavif
    mozjpeg
    oxipng
    nodePackages.svgo

    # KDE connect
    kdePackages.kdeconnect-kde

    # Productivity
    libreoffice
    protonmail-bridge

    # System utilities
    brightnessctl
    libnotify
    xdg-utils
    gammastep
    usbutils

    # VPN
    proton-vpn-cli

    # Others
    qbittorrent
    flatpak

    # Added for Radicale
    apacheHttpd
  ];

  # Android tooling
  # programs.adb.enable = true;
  # users.users.phatle.extraGroups = [ "adbusers" ];

  services.resolved.enable = true;
  services.proton-vpn-cli.enable = true;
  services.protonmail-bridge.enable = true;
  programs.kdeconnect.enable = true;

  systemd.user.services.kdeconnect = {
    description = "KDE Connect daemon";
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.kdePackages.kdeconnect-kde}/bin/kdeconnectd";
      Restart = "on-failure";
      RestartSec = 3;
    };
    environment = {
      # Ensure proper DBus session
      DISPLAY = ":0";
    };
  };

  networking.firewall = {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
  };

  # Enable flatpak
  services.flatpak.enable = true;

  # Syncthing for laptop to phone synchronization
  services.syncthing = {
    enable = true;
    user = "phatle";
    dataDir = "/home/phatle/.syncthing";
    configDir = "/home/phatle/.config/syncthing";
    # Can declaratively set this later:
    # overrideDevices = true;
    # overrideFolders = true;

    settings = {
      devices = {
        "phone" = {
          id = "";
        };
      };
    };
  };

  # Radicale testing for server calendar/VCard sync
  # services.radicale = {
  #  enable = true;
  #  settings = {
  #    server = {
  #      hosts = [ "0.0.0.0:5232" ]; # Localhost only for testing
  #    };
  #    auth = {
  #      type = "htpasswd";
  #      htpasswd_filename = "/var/lib/radicale/users";
  #      htpasswd_encryption = "bcrypt";
  #    };
  #    storage = {
  #      filesystem_folder = "/var/lib/radicale/collections";
  #    };
  #    logging = {
  #      level = "info"; # Helpful for debugging during testing
  #    };
  #  };
  #};

  networking.firewall = {
  };
}
