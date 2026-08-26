{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hm-config = {
      url = "github:dprive05/home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        hyprland.follows = "hyprland";
        zen-browser.follows = "zen-browser";
        catppuccin.follows = "catppuccin";
        nixvim.follows = "nixvim";
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    nixvim = {
      url = "github:EniumRaphael/nixvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      agenix,
      nixos-hardware,
      hm-config,
      home-manager,
      zen-browser,
      hyprland,
      catppuccin,
      nixvim,
      ...
    }@inputs:

    let
      mkHomeManagerModule = userModules: extraSpecialArgs: {
        home-manager.sharedModules = [
          catppuccin.homeModules.catppuccin
        ];
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hmbak";
        home-manager.extraSpecialArgs = extraSpecialArgs;
        home-manager.users = userModules;
      };

      mkHost =
        {
          sys ? "x86_64-linux",
          nixName,
          hostModules,
          userModules ? {
            raph = import hm-config.outputs.homeModules.${nixName};
            root = import hm-config.outputs.homeModules.root;
          },
          extraModules ? [ ],
        }:
        let
          hmPackages = {
            zen-browser = inputs.zen-browser.packages.${sys}.default;
            nixvim = nixvim.packages.${sys}.default;
          };
        in
        nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/${nixName}/configuration.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            (mkHomeManagerModule userModules (
              {
                inherit inputs;
              }
              // hmPackages
            ))
          ]
          ++ hostModules
          ++ extraModules;
          specialArgs = { inherit inputs nixName; };
        };
    in
    {
      nixosConfigurations = {
        "framework" = mkHost {
          sys = "x86_64-linux";
          nixName = "framework";
          hostModules = [
            nixos-hardware.nixosModules.framework-16-7040-amd
          ];
        };
        "server" = mkHost {
          sys = "x86_64-linux";
          nixName = "server";
          hostModules = [ ];
        };
      };
    };
}
