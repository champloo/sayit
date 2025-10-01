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
        pkgs = import nixpkgs { inherit system; };

        whisper = pkgs.whisper-cpp.override { cudaSupport = true; };
        deps = [
          whisper
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
