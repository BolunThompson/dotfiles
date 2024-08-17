{
  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland"; agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agenix.inputs.darwin.follows = "";
    };
    # TODO: Install ranger archives plugin for ranger
    # ranger-archives.url = "github:maximtrp/ranger-archives";
  };
  outputs =  {self, nixpkgs, home-manager, hyprland, agenix, ... }@attrs: {
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
        }
      ];
      specialArgs = {
        inputs = attrs;
        nvim-remote = nixpkgs.vimUtils.buildVimPlugin { pname = "nvim-remote"; version = "HEAD"; src = builtins.fetchGit { url = "https://github.com/amitds1997/remote-nvim.nvim.git"; ref = "HEAD"; }; };
        # hard coded until I can figure out how to read it
        ip = {
          public-ip = "76.88.2.159";
          private-ip = "192.168.0.167";
        };
      };
    };
    homeConfigurations."bolun@nixos" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        agenix.homeManagerModules.age
        hyprland.homeManagerModules.default
        { wayland.windowManager.hyprland.enable = true; }
      ];
    };
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
  };
}
