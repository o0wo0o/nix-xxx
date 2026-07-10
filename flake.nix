{
  description = "Nixos system configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-hardware,
      nix-flatpak,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        nixsos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nixos-hardware.nixosModules.lenovo-thinkpad-l14-amd
            nix-flatpak.nixosModules.nix-flatpak
            home-manager.nixosModules.home-manager

            ./configuration.nix
          ];
        };
      };
    };
}
