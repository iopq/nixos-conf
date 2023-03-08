{
  description = "NixOS configuration with two or more channels";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable"; 
    nixpkgs-stable.url = "nixpkgs/nixos-22.05"; 
  };

  
  outputs = { self, nixpkgs, nixpkgs-stable }:
    let
      system = "x86_64-linux";
        overlay-stable = final: prev: {
          stable = import nixpkgs-stable {
           inherit system;
           config.allowUnfree = true;
          };
      };
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Overlays-module makes "pkgs.stable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-stable
            (_: _: { xray = pkgs.callPackage ./xray/default.nix {} ;} )  
            (_: _: { v2raya = pkgs.callPackage ./xraya/default.nix {} ;} ) 
          ]; })
          ./configuration.nix
        ];
      };
    };
}
 
