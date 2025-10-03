# Sayit

A tiny Bash script that listens to your system microphone, transcribes speech locally with Whisper (via whisper-cli), cleans up the text, and “types” it into the active window using `wtype`.

Run it once to start listening. Run it again to stop and paste the result—no tray icons, no GUI, just a simple toggle.

## Features

- Speech transcription using [whisper.cpp](https://github.com/ggml-org/whisper.cpp)
- Direct text input to any focused application using [wtype](https://github.com/atx/wtype)
- GPU acceleration support via CUDA where available
- Simple toggle mechanism to start/stop recording
- Minimal shell script implementation

## How it Works

Sayit captures audio from your default audio input, processes it through Whisper for speech recognition, and automatically types the transcribed text using `wtype`. The tool uses a quit file mechanism for clean start/stop control.

## Prerequisites

- **Linux system** (x86_64 or aarch64)
- **Nix package manager** with flakes enabled
- **Working microphone** connected to your system
- **Wayland** (required for putting text in active window via `wtype`)
- Uses GGML Whisper small model by default which needs to exist at `$HOME/.local/share/whisper/ggml-small.en.bin`.
  - You can [download](https://huggingface.co/ggerganov/whisper.cpp/tree/main) other GGML models and use those instead by setting `GGML_MODEL_PATH`

## Installation

As Whisper.cpp is compiled with CUDA support unfree packages need to be allowed.

Add to you nixos config...

```nix
# flake.nix

inputs = {
  sayit.url = "github:champloo/sayit";
  sayit.inputs.nixpkgs.follows = "nixpkgs";
};

outputs = {
  # Add it to nixpkgs overlay so that it inherits your unfree settings
  nixosConfigurations = {
    configName = nixpkgs.lib.nixosSystem {
      specialArgs = { inherits inputs; };
      modules = [
        (
          { pkgs, inputs, ... }:
          {
            nixpkgs.overlays = [
              inputs.sayit.overlays.default
            ];
          }
        )
        ./configuration.nix
      ];
  };
}

# configuration.nix

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      # sayit dependencies
      "cuda_cccl"
      "cuda_cudart"
      "libcublas"
      "cuda_nvcc"
    ];
  
  # Alternativelly you can allow unfree for all packages.
  # nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
     sayit
  ];
```

You can also try it out by running  directly from shell...

```bash
NIXPKGS_ALLOW_UNFREE=1 nix run github:champloo/sayit --impure
```

## Usage

1. **Start recording**: Run `sayit` to begin capturing audio
2. **Stop recording**: Run `sayit` again to stop recording and type the transcribed text
3. The transcribed text will be automatically typed into whatever application currently has focus

You can set up a keybinding for `sayit` to allow you to quickly start and stop transcription.

