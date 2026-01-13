{ config, lib, pkgs, ...  }:

{
  environment.systemPackages = with pkgs; [
    # Python
    python3
    python3Packages.pip
    python3Packages.virtualenv
    
    # Python LSPs
    pyright            # Microsoft Python LSP
    ruff              # Fast Python linter/formatter
    
    # Formatting/Linting
    python3Packages.black
    python3Packages.isort
    python3Packages.pylint
    
    # Type checking
    python3Packages.mypy
    
    # Debugging
    python3Packages.debugpy
  ];
}
