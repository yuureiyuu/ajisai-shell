{
  description = "NixOS Flake for Yuu";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    #zen-browser.url = "github:0xc000022070/zen-browser-flake";

    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    colloid-icons = {
    url = "github:SueDonham/Colloid-pastel-icons";
    flake = false;
    };

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix";
  };


  outputs = inputs@{ self, nixpkgs, home-manager, colloid-icons, nix4nvchad, catppuccin, ... }: {

    nixosConfigurations.yuurei = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs colloid-icons; };

      modules = [
        { nixpkgs.hostPlatform = "x86_64-linux"; } 
        
        ./hosts/configuration.nix
        ./hosts/hardware-configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = { inherit inputs colloid-icons nix4nvchad; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.yuu.imports = [
            catppuccin.homeModules.catppuccin
            ./home/home.nix
          ];
        }
     ];
    };
  };
}
