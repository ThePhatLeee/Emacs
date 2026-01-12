{ config, lib, pkgs, ... }: 

{
  environment.systemPackages = with pkgs; [
    # Lua
    lua
    luajit
    luarocks
    
    # Lua LSP
    lua-language-server
    
    # Formatting
    stylua
  ];
}
