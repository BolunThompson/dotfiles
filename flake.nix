{
  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agenix.inputs.darwin.follows = "";
    };
    admin-scripts.url = "github:BolunThompson/admin-scripts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = { self, nixpkgs, home-manager, hyprland, admin-scripts, agenix, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./configuration.nix
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.bolun.imports = [
            agenix.homeManagerModules.default
            ./home.nix
          ];
          home-manager.extraSpecialArgs = {
              admin-scripts = admin-scripts;
          };

        }
      ];
      specialArgs = {
        inputs = inputs;
        hyprland = hyprland;
        # hard coded until I can figure out how to read it
        ip = {
          public-ip = "76.88.2.159";
          private-ip = "192.168.0.167";
        };
      };
    };
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
  };
}
