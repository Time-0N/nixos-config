{
  description = "My NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Add Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
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
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs vars; };
            home-manager.users.timeon = import ./home.nix;
            # Makes backups of old configs. (Must be deleted manualy!)
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
    };
}
