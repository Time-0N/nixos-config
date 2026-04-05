{
  description = "My NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hypr-bucket.url = "github:Time-0N/hypr-bucket";
    zen-browser.url = "github:0xc000022070/zen-browser-flake/beta";
    gazelle.url = "github:Zeus-Deus/gazelle-tui";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixvim,
      ...
    }@inputs:
    let
      vars = import ./hosts/mercury/variables.nix;
    in
    {
      nixosConfigurations.mercury = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs vars; };
        modules = [
          ./hosts/mercury/configuration.nix
          inputs.nix-flatpak.nixosModules.nix-flatpak
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs vars; };
            home-manager.users.timeon = import ./modules/home/default.nix;
            home-manager.sharedModules = [
              nixvim.homeModules.nixvim
            ];
          }
        ];
      };
    };
}
