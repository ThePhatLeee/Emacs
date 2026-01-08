{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.stylix.homeModules.stylix
    ./activation.nix
    ./dotfiles.nix
    ./emacs.nix
    ./firefox.nix
    ./gpg.nix
    ./media.nix
    ./theming.nix
    ./xdg.nix
    ./kanshi.nix
  ];

  home.username = "phatle";
  home.homeDirectory = "/home/phatle";
  home.stateVersion = "25.11";

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
  };
}
