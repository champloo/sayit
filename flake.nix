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
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        deps = [
          (pkgs.whisper-cpp.override { cudaSupport = true; })
          pkgs.wtype
          pkgs.ffmpeg
        ];
      in
      {
        packages.sayit = pkgs.writeShellApplication {
          name = "sayit";
          runtimeInputs = deps;
          text = builtins.readFile ./sayit;
        };
        packages.default = self.packages.${system}.sayit;

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.sayit}/bin/sayit";
        };
        devShells.default = pkgs.mkShell {
          packages = [ self.packages.${system}.sayit ] ++ deps;
        };
      }
    );
}
