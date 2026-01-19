{ config, pkgs, ... }:
{
  home.activation = {
   # Create necessary directories
    createDirectories = config.lib.dag.entryBefore [ "linkGeneration" ] ''
      # Create directory structure
      mkdir -p ${config.home.homeDirectory}/+STORE/dictionary
      mkdir -p ${config.home.homeDirectory}/.elfeed
      mkdir -p ${config.home.homeDirectory}/.cache/spotifyd
      mkdir -p ${config.home.homeDirectory}/org
      mkdir -p ${config.home.homeDirectory}/org/roam
      mkdir -p ${config.home.homeDirectory}/org/roam/contacts
      mkdir -p ${config.home.homeDirectory}/org/roam/books
      mkdir -p ${config.home.homeDirectory}/org/roam/people
      mkdir -p ${config.home.homeDirectory}/org/roam/tech
      mkdir -p ${config.home.homeDirectory}/org/roam/faith/theology
      mkdir -p ${config.home.homeDirectory}/org/roam/writing
      mkdir -p ${config.home.homeDirectory}/org/roam/projects
      mkdir -p ${config.home.homeDirectory}/org/roam/concepts
      mkdir -p ${config.home.homeDirectory}/MusicOrganized
      mkdir -p ${config.home.homeDirectory}/secrets
      mkdir -p ${config.home.homeDirectory}/.local/share/gnus
      mkdir -p ${config.home.homeDirectory}/.local/share/gnus/news
      mkdir -p ${config.home.homeDirectory}/.local/share/gnus/mail
      mkdir -p ${config.home.homeDirectory}/.local/share/gnus/saved
      mkdir -p ${config.home.homeDirectory}/.local/share/doom
      
      echo "Directory structure created"
    ''; 
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
