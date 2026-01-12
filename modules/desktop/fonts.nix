# modules/desktop/fonts.nix
# Font packages and configuration

{ config, pkgs, lib, ...  }:

{
  # Font packages
  fonts.packages = with pkgs; [
    alegreya
    nerd-fonts.geist-mono
    montserrat
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    jetbrains-mono
  ];

  # Font configuration
  fonts. fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Alegreya" ];
      sansSerif = [ "Montserrat" ];
      monospace = [ "GeistMono Nerd Font" ];
    };
  };
}
