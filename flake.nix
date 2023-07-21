{
  description = "NixOS configuration with two or more channels";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable"; 
    nixpkgs-stable.url = "nixpkgs/nixos-22.05";
    nix-software-center.url = "github:vlinkz/nix-software-center";
    nur.url = github:nix-community/NUR;
  };

  
  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, nix-software-center, nur}:
    let
      system = "x86_64-linux";
      overlay-stable = final: prev: {
        stable = import nixpkgs-stable {
         inherit system;
         config.allowUnfree = true;
        };
      };
    in {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nur.nixosModules.nur
          # Overlays-module makes "pkgs.stable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-stable
          #  (_: _: { xray = pkgs.callPackage ./xray/default.nix {} ;} )  
          #  (_: _: { v2raya = pkgs.callPackage ./xraya/default.nix {} ;} ) 
             nur.overlay
          ]; })
          ./configuration.nix
        ];
        specialArgs = {
          inherit inputs;
        };
      };
    };
}
 
