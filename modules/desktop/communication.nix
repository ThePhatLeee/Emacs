{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    signal-desktop
    dino
    thunderbird
  ];
}
