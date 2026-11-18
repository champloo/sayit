{
  lib,
  config,
  writeShellApplication,
  whisper-cpp,
  wtype,
  ffmpeg,

  # Same convention as nixpkgs' ollama: null follows nixpkgs.config.cudaSupport
  # and rocmSupport; false forces CPU.
  acceleration ? null,
}:

assert builtins.elem acceleration [
  null
  false
  "cuda"
  "rocm"
  "vulkan"
];

let
  cudaRequested = acceleration == "cuda" || (acceleration == null && config.cudaSupport);
  # whisper.cpp cannot build with CUDA and ROCm at once, so CUDA wins when the
  # config enables both.
  rocmRequested =
    acceleration == "rocm" || (acceleration == null && config.rocmSupport && !cudaRequested);
  vulkanRequested = acceleration == "vulkan";

  runtimeInputs = [
    (whisper-cpp.override {
      cudaSupport = cudaRequested;
      rocmSupport = rocmRequested;
      vulkanSupport = vulkanRequested;
    })
    wtype
    ffmpeg
  ];
in
writeShellApplication {
  name = "sayit";
  inherit runtimeInputs;
  text = builtins.readFile ./sayit;
  # Lets the dev shell run ./sayit straight from the checkout.
  passthru = { inherit runtimeInputs acceleration; };
  meta.platforms = lib.platforms.linux;
}
