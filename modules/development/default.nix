{ config, pkgs, ... }:
{
  imports = [
    ./base.nix
    ./doom.nix
    ./go.nix
    ./python.nix
    ./rust.nix
    ./web.nix       
    ./php.nix       
    ./cpp.nix       
    ./lua.nix       
    ./markup.nix
  ];
}
