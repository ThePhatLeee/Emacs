{ config, lib, pkgs, ... }: 

{
  environment.systemPackages = with pkgs; [
    # C/C++
    gcc
    clang
    cmake
    gnumake
    gdb
    lldb
    
    # C/C++ LSP
    clang-tools        # clangd LSP
    ccls               # Alternative C/C++ LSP
    
    # C# (via . NET)
    dotnet-sdk
    omnisharp-roslyn   # C# LSP
    
    # Build tools
    ninja
    meson
  ];
}
