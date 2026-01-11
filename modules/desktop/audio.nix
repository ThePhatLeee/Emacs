{ config, pkgs, ... }:
{
  # Disable PulseAudio in favor of PipeWire
  services.pulseaudio.enable = false;

  # Enable real-time audio support
  security.rtkit.enable = true;

  # PipeWire configuration
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # Uncomment if you need JACK support
    # jack.enable = true;
  };
    # Audio Fidelity
  services.pipewire.extraConfig.pipewire = {
    "99-high-fidelity" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [ 44100 48000 88200 96000 ];
        "default.clock.quantum" = 1024;
      };
    };
  };


  # Audio packages
  environment.systemPackages = with pkgs; [
    pavucontrol
    playerctl
    wireplumber
    alsa-utils
  ];
}
