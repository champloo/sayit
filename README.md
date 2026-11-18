# 📢 Sayit

A tiny Bash script that listens to your system microphone, transcribes speech locally with Whisper (via whisper-cli), cleans up the text, and “types” it into the active window using `wtype`.

Run it once to start listening. Run it again to stop and paste the result—no tray icons, no GUI, just a simple toggle.

## ✨ Features

- 🎤 Speech transcription using [whisper.cpp](https://github.com/ggml-org/whisper.cpp) `small.en` model
- 🔧 Select a different model by specifying `WHISPER_MODEL` environment variable
- 📥 Automatically downloads the selected Whisper model to `XDG_DATA_HOME\whisper`
- ⌨️ Direct text input to any focused application using [wtype](https://github.com/atx/wtype)
- 🚀 GPU acceleration via CUDA (NVIDIA), ROCm (AMD) or Vulkan (any vendor)
- 🔄 Simple toggle mechanism to start/stop recording
- 🪶 Minimal shell script implementation

## ⚙️ How it Works

Sayit captures audio from your default audio input via ffmpeg, processes it through Whisper for speech recognition, and automatically types the transcribed text using `wtype`. The tool uses a quit file mechanism for clean start/stop control.

## 📋 Prerequisites

- 🐧 **Linux system** (x86_64 or aarch64)
- ❄️ **Nix package manager** with flakes enabled
- 🎤 **Working microphone** connected to your system
- 🪟 **Wayland** (required for putting text in active window via `wtype`)

## 📦 Installation

Like other GPU packages in nixpkgs, `sayit` follows your nixpkgs config. It
uses CUDA when `nixpkgs.config.cudaSupport = true` and ROCm when
`nixpkgs.config.rocmSupport = true`; with neither set, it runs on the CPU.
To pick a backend for sayit alone, use one of these packages instead:

| Package        | Backend                       | Unfree packages needed |
|----------------|-------------------------------|------------------------|
| `sayit-cuda`   | NVIDIA (CUDA)                 | Yes                    |
| `sayit-rocm`   | AMD (ROCm)                    | No                     |
| `sayit-vulkan` | Any Vulkan GPU (AMD, Intel…)  | No                     |
| `sayit-cpu`    | CPU only                      | No                     |

You can also set the backend with an override, e.g.
`sayit.override { acceleration = "vulkan"; }`. Valid values are `"cuda"`,
`"rocm"`, `"vulkan"` and `false` (CPU only).

On AMD, try Vulkan first; it is a much smaller install than ROCm.

Add to your NixOS config...

```nix
# flake.nix

inputs = {
  sayit.url = "github:champloo/sayit";
  sayit.inputs.nixpkgs.follows = "nixpkgs";
};

outputs = {
  # Add it to nixpkgs overlay so that it inherits your nixpkgs config
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

  # NVIDIA: CUDA is unfree, so it has to be allowed.
  nixpkgs.config.cudaSupport = true;
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

  # AMD: either set this, or skip it and install sayit-vulkan.
  # nixpkgs.config.rocmSupport = true;

  environment.systemPackages = with pkgs; [
     sayit
  ];
```

Setting `cudaSupport` or `rocmSupport` affects every package that supports
it, not just sayit. If you only want GPU acceleration for sayit, leave the
config alone and install `sayit-cuda`, `sayit-rocm` or `sayit-vulkan`.

You can also try it out by running  directly from shell...

```bash
# NVIDIA
NIXPKGS_ALLOW_UNFREE=1 nix run github:champloo/sayit#sayit-cuda --impure

# AMD and other Vulkan GPUs
nix run github:champloo/sayit#sayit-vulkan

# CPU only
nix run github:champloo/sayit
```

## 📖 Usage

1. **Start recording**: Run `sayit` to begin capturing audio
2. **Stop recording**: Run `sayit` again to stop recording and type the transcribed text
3. The transcribed text will be automatically typed into whatever application currently has focus

You can set up a keybinding for `sayit` to allow you to quickly start and stop transcription.

