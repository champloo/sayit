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
      depsFor = pkgs: [
        (pkgs.whisper-cpp.override { cudaSupport = true; })
        pkgs.wtype
        pkgs.ffmpeg
      ];

      overlay = final: prev: {
        sayit = final.writeShellApplication {
          name = "sayit";
          runtimeInputs = depsFor final;
          text = builtins.readFile ./sayit;
        };
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
        packages.sayit = withOverlay.sayit;

        packages.default = withOverlay.sayit;

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.sayit}/bin/sayit";
        };
        devShells.default = pkgs.mkShell {
          packages = [ withOverlay.sayit ] ++ depsFor pkgs;
        };
      }
    );
}
