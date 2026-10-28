{
  description = "Delta desktop app packaged for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.delta-upstream = {
    url = "github:zed-industries/delta-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      delta-upstream,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      packageFor =
        system:
        (pkgsFor system).callPackage ./packages/delta.nix {
          upstream = delta-upstream.packages.${system}.default;
        };
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
          program = "${self.packages.${system}.delta}/bin/zed-delta";
          meta.description = "Run Delta";
        };
      });

      checks = forAllSystems (system: {
        delta = self.packages.${system}.delta;
      });

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      overlays.default = final: _previous: {
        delta = final.callPackage ./packages/delta.nix {
          upstream = delta-upstream.packages.${final.stdenv.hostPlatform.system}.default;
        };
      };

      nixosModules.default = import ./modules/nixos.nix { inherit self; };
      homeManagerModules.default = import ./modules/home-manager.nix { inherit self; };
    };
}
