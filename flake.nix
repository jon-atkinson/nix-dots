{
  description = "nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim.url = "github:nix-community/nixvim";
    nix-colors.url = "github:Misterio77/nix-colors";
    nvim-config.url = "github:jon-atkinson/nvimConfigs";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixvim,
      nix-colors,
      nvim-config,
      ...
    }@inputs:
    let
      user = "jon";
    in
    {
      nixosConfigurations = {
        nixos-laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };

          modules = [
            ./hosts/nixos-laptop.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${user} = {
                  home.username = "jon";
                  home.homeDirectory = "/home/jon";
                  home.stateVersion = "25.05";
                  imports = [
                    ./home/nixos/hyprland.nix
                    ./home/nixos/fonts.nix
                    ./home/shared/default.nix
                    ./home/shared/nixvim.nix
                    ./home/shared/zellij.nix
                    ./home/shared/zsh.nix
                    inputs.nix-colors.homeManagerModules.default
                  ];
                };
                extraSpecialArgs = { inherit inputs; };
              };
            }
          ];
        };

        nixos-wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };

          modules = [
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${user} = {
                  home.username = "jon";
                  home.homeDirectory = "/home/jon";
                  home.stateVersion = "25.05";
                  imports = [
                    ./home/shared/default.nix
                    ./home/shared/nixvim.nix
                    ./home/shared/zellij.nix
                    ./home/shared/zsh.nix
                    inputs.nix-colors.homeManagerModules.default
                  ];
                };
                extraSpecialArgs = { inherit inputs; };
              };
            }
          ];
        };
      };

      homeConfigurations = {
        darwin = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
          modules = [
            {
              home.username = "Jon";
              home.homeDirectory = "/Users/Admin";
              home.stateVersion = "25.05";
              imports = [
                ./home/shared/default.nix
                ./home/shared/nixvim.nix
                ./home/shared/zellij.nix
                ./home/shared/zsh.nix
                inputs.nix-colors.homeManagerModules.default
              ];
            }
          ];
          extraSpecialArgs = { inherit inputs; };
        };

        linux-generic-headless = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          modules = [
            {
              targets.genericLinux.enable = true;
              home.username = "jon";
              home.homeDirectory = "/home/jon";
              home.stateVersion = "25.05";
              imports = [
                ./home/shared/default.nix
                ./home/shared/nixvim.nix
                ./home/shared/zellij.nix
                ./home/shared/zsh.nix
                inputs.nix-colors.homeManagerModules.default
              ];
            }
          ];
          extraSpecialArgs = { inherit inputs; };
        };
      };
    };
}
