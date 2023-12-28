{
  description = "NixOS configuration with two or more channels";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable"; 
    nixpkgs-stable.url = "nixpkgs/nixos-23.11";
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

          ({ pkgs, ... }:
            let
              nur-no-pkgs = import nur {
                nurpkgs = import nixpkgs { system = "x86_64-linux"; };
              };
            in {
              imports = [ nur-no-pkgs.repos.iopq.modules.xraya  ];
              #services.xraya.enable = true;
          })
          
          # Overlays-module makes "pkgs.stable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [
            overlay-stable
#            (_: _: { v2raya = pkgs.callPackage /etc/nixos/v2raya/default.nix {} ;} )
  #          (_: _: { nur-no-pkgs.repos.iopq.modules.xraya = pkgs.callPackage /etc/nixos/xraya/default.nix {} ;} ) 
#            (final: prev: { v2raya = prev.v2raya.override { v2ray = final.xray; }; })
#            (final: prev: { v2raya = prev.v2raya.overrideAttrs(_: { src = /home/iopq/sw/v2rayA; }) ;} )
          ]; })
          
          ./configuration.nix
        ];
        specialArgs = {
          inherit inputs;
        };
      };
    };
}
 
