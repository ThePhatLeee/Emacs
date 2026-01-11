{
  description = "Joshua Blais' NixOS Infrastructure";

  inputs = {
    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nur.url = "github:nix-community/NUR";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0";



    # Tools
    disko.url = "github:nix-community/disko";
    home-manager.url = "github:nix-community/home-manager";
    deploy-rs.url = "github:serokell/deploy-rs";
    agenix.url = "github:ryantm/agenix";
    impermanence.url = "github:nix-community/impermanence";

    # Custom modules
    supernote-tools.url = "github:jblais493/supernote";

    # Styling
    stylix.url = "github:danth/stylix";

    # Pin all inputs to main nixpkgs
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    supernote-tools.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      lib = nixpkgs.lib;

      # Common modules for all systems
      base = [
        inputs.agenix.nixosModules.default
      ];

      # Desktop machines get base + GUI tools
      desktop = base ++ [
        inputs.supernote-tools.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.phatle = import ./modules/home-manager;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.backupFileExtension = "backup";
        }
      ];

      # Build a NixOS system configuration
      mkHost =
        hostname: modules:
        lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [ ./hosts/${hostname}/configuration.nix ] ++ modules;
        };

      # Build a deploy-rs deployment target
      mkDeploy = hostname: cfg: {
        hostname = cfg.hostname; # Use the hostname from cfg, not the parameter
        profiles.system = {
          user = "root";
          sshUser = cfg.sshUser or "root";
          path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${hostname}; # Use hostname for config lookup
        };
      };

    in
    {
      # System configurations
      nixosConfigurations = {
        # Personal machines (desktop environment)
         nixos = mkHost "nixos" desktop;

        # Server infrastructure (headless)
        
      };

      # Remote deployment targets
      
      # Deployment validation checks
      checks = builtins.mapAttrs (_: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
    };
}
