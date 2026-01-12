{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # PHP
    php
    phpPackages.composer
    
    # PHP LSP and tools
    phpactor          # PHP LSP
    phpPackages.phpstan
    phpPackages.php-cs-fixer
    
    # Debugging
    phpExtensions.xdebug
  ];
}
