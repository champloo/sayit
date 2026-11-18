{
  description = "Sayit, a speech to text tool";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      overlay = final: prev: {
        sayit = final.callPackage ./package.nix { };
        sayit-cpu = final.sayit.override { acceleration = false; };
        sayit-cuda = final.sayit.override { acceleration = "cuda"; };
        sayit-rocm = final.sayit.override { acceleration = "rocm"; };
        sayit-vulkan = final.sayit.override { acceleration = "vulkan"; };
      };
    in
    {
      overlays.default = overlay;
    }
    // flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        withOverlay = pkgs.extend overlay;
      in
      {
        packages = {
          inherit (withOverlay)
            sayit
            sayit-cpu
            sayit-cuda
            sayit-rocm
            sayit-vulkan
            ;
          default = withOverlay.sayit;
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.sayit}/bin/sayit";
        };
        devShells.default = pkgs.mkShell {
          packages = [ withOverlay.sayit ] ++ withOverlay.sayit.runtimeInputs;
        };
      }
    );
}
