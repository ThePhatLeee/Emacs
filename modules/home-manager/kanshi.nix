{ pkgs, ... }: {
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    settings = [
      {
        profile.name = "undocked";
        profile.outputs = [{
          criteria = "eDP-1";
          status = "enable";
          mode = "3456x2160@60Hz";
          position = "0,0"; 
          scale = 1.2; 
        }];
        profile.exec = [
          "hyprctl reload"
          "systemctl --user reload waybar"
          # Aggressively force inputs and focus
          "hyprctl keyword input:touchpad:enabled true"
          "hyprctl dispatch workspace 1"
          "notify-send -a 'System' -i 'computer' 'Mobile Mode' 'Internal Display Ready'"
        ];
      }

      {
        profile.name = "docked";
        profile.outputs = [
          { criteria = "eDP-1"; status = "disable"; }
          {
            criteria = "DP-3"; 
            status = "enable";
            mode = "3440x1440@60Hz";
            position = "0,0"; 
            scale = 1.0; 
          }
        ];
        profile.exec = [
          "hyprctl reload"
          "systemctl --user reload waybar"
          
          # Force Workspace 1 to external screen
          "hyprctl dispatch moveworkspacetomonitor 1 DP-3"
          "hyprctl dispatch workspace 1"
          
          "notify-send -a 'System' -i 'video-display' 'Docked Mode' 'Workspace 1 Active'"
          "swaync-client -d" 
        ];
      }
    ];
  };

    # --- HYPRLAND INPUT FIX ---
  systemd.user.services.hyprland-input-fix = {
    Unit = {
      Description = "Force Hyprland input re-scan and UI refresh";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.hyprland}/bin/hyprctl reload";
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };

}

