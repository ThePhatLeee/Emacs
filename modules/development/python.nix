{ config, lib, pkgs, ...  }:

{
  environment. systemPackages = with pkgs; [
    # Python
    python
    pythonPackages.pip
    pythonPackages.virtualenv
    
    # Python LSPs
    pyright            # Microsoft Python LSP
    ruff              # Fast Python linter/formatter
    ruff-lsp          # Ruff LSP
    
    # Formatting/Linting
    pythonPackages.black
    pythonPackages.isort
    pythonPackages.pylint
    
    # Type checking
    pythonPackages.mypy
    
    # Debugging
    pythonPackages.debugpy
  ];
}
