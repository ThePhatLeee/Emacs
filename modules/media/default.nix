{ config, pkgs, ... }:
{
  imports = [
    ./davinci.nix
    ./images.nix
    ./music.nix
    ./pdf.nix
    ./video.nix
  ];
}
