{ config, lib, pkgs, ... }: 

{
  environment.systemPackages = with pkgs; [
    # Node.js ecosystem
    nodejs
    nodePackages.npm
    nodePackages.pnpm
    nodePackages. yarn
    
    # TypeScript/JavaScript
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.ts-node
    nodePackages.eslint
    nodePackages.prettier
    
    # React dev tools
    nodePackages.create-react-app
    
    # CSS/SASS
    nodePackages.sass
    nodePackages.vscode-langservers-extracted  # cssls, html, json, eslint LSPs
    
    # Tailwind
    nodePackages.tailwindcss
    nodePackages."@tailwindcss/language-server"
    
    # Emmet
    emmet-ls
    
    # Build tools
    vite
    webpack
  ];
}
