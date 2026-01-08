{ config, pkgs, ... }:
{
  home.activation = {
    # Repository cloning
    
    # Doom sync
    syncDoomEmacs = config.lib.dag.entryAfter [ "linkGeneration" "installDoomEmacs" ] ''
      if [ -d "${config.home.homeDirectory}/.emacs.d" ] && \
         [ -d "${config.home.homeDirectory}/.config/doom" ]; then
        if [ -x "${config.home.homeDirectory}/.emacs.d/bin/doom" ]; then
          echo "Syncing Doom configuration..."
          export PATH="${pkgs.emacs}/bin:${pkgs.git}/bin:${pkgs.ripgrep}/bin:${pkgs.fd}/bin:$PATH"
          ${config.home.homeDirectory}/.emacs.d/bin/doom sync
        else
          echo "Warning: doom binary not found, skipping sync"
        fi
      else
        echo "Doom or doom config not found, skipping sync"
      fi
    '';
  };
}
