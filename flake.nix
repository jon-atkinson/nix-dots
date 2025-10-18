{
  description = "Jon's nix config";

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
      mkHomeConfig =
        mode: system: username: userhomedir:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = [
            {
              home.username = username;
              home.homeDirectory = userhomedir;
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
          extraSpecialArgs = { inherit inputs mode; };
        };
      mkNixosSystem =
        mode: system: hostModules: homeManagerModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = hostModules ++ [
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.jon = {
                  home.username = "jon";
                  home.homeDirectory = "/home/jon";
                  home.stateVersion = "25.05";
                  imports = [
                    ./home/shared/default.nix
                    ./home/shared/nixvim.nix
                    ./home/shared/zellij.nix
                    ./home/shared/zsh.nix
                    ./home/nixos/fonts.nix
                    ./home/nixos/plocate.nix
                    inputs.nix-colors.homeManagerModules.default
                  ]
                  ++ homeManagerModules;
                };
                extraSpecialArgs = { inherit inputs mode; };
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        nixos-wm =
          mkNixosSystem "personal" "x86_64-linux"
            [ ./hosts/nixos-laptop.nix ]
            [ ./home/nixos/hyprland.nix ];
        linux-wsl-work = mkNixosSystem "work" "x86_64-linux" [ ] [ ];
      };

      homeConfigurations = {
        darwin-personal = mkHomeConfig "personal" "aarch64-darwin" "Jon" "/Users/Admin/";
        darwin-work = mkHomeConfig "work" "aarch64-darwin" "Jon" "/Users/Admin/";

        linux-personal = mkHomeConfig "personal" "x86_64-linux" "jon" "/home/jon/";
        linux-work = mkHomeConfig "work" "x86_64-linux" "jon" "/home/jon/";
      };
    };
}
