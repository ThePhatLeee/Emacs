{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    signal-desktop
    signal-cli
    gurk-rs
    dino
    thunderbird
  ];
}
