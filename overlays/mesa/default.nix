{ channels, inputs, ... }:

final: prev: {
  upstream.mesa = prev.mesa.overrideAttrs (_: {
    version = builtins.substring 0 (builtins.stringLength prev.mesa.version) inputs.mesa.rev;
    src = inputs.mesa;
    patches = [
      (final.fetchpatch {
        url = "https://raw.githubusercontent.com/chaotic-cx/nyx/refs/heads/main/pkgs/mesa-git/opencl.patch";
        hash = "sha256-pWmkdoA1QkGvXqhy5NMKXN6fPUJJm+9eHW/7p1YIj1k=";
      })
    ];
  });
}
