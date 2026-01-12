{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Markdown
    marksman           # Markdown LSP
    markdown-oxide     # Alternative Markdown LSP
    pandoc             # Markdown conversion
    
    # YAML
    yaml-language-server
    yamllint
    
    # TOML
    taplo              # TOML LSP
  ];
}
