{
  description = "Delta desktop app packaged for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      packageFor = system: nixpkgs.legacyPackages.${system}.callPackage ./packages/delta.nix { };
    in
    {
      packages = forAllSystems (
        system:
        let
          delta = packageFor system;
        in
        {
          inherit delta;
          default = delta;
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.delta}/bin/delta";
          meta.description = "Run Delta";
        };
      });

      checks = forAllSystems (system: {
        delta = self.packages.${system}.delta;
      });

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      overlays.default = final: _previous: {
        delta = final.callPackage ./packages/delta.nix { };
      };

      nixosModules.default = import ./modules/nixos.nix { inherit self; };
      homeManagerModules.default = import ./modules/home-manager.nix { inherit self; };
    };
}
