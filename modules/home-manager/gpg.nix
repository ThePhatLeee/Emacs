{ config, pkgs, ... }:
{
  programs.gpg = {
    enable = true;
    settings = {
      # Use agent
      use-agent = true;
      # Default key (will be set after key generation)
       default-key = "09D801B2351193B1";
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 86400;
    maxCacheTtl = 86400;
    
    # Use curses for CLI, Qt for GUI
    pinentryPackage = pkgs.pinentry-curses;
    
    extraConfig = ''
      allow-loopback-pinentry
      allow-emacs-pinentry
    '';
  };

  # Ensure pass is available
  home.packages = with pkgs; [
    pass
    passff-host  # Browser integration
  ];
}
