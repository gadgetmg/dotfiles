{ channels, inputs, ... }:

final: prev: {
  upstream = prev.lib.makeScope prev.newScope (_: {
    hwdata = prev.hwdata.overrideAttrs (
      finalAttrs: prevAttrs: {
        version = "0.393";
        src = final.fetchFromGitHub {
          owner = "vcrhonek";
          repo = "hwdata";
          rev = "v${finalAttrs.version}";
          hash = "sha256-RDp5NY9VYD0gylvzYpg9BytfRdQ6dim1jJtv32yeF3k=";
        };
      }
    );
    mesa = prev.mesa.overrideAttrs (_: {
      version = builtins.substring 0 (builtins.stringLength prev.mesa.version) inputs.mesa.rev;
      src = inputs.mesa;
      patches = [
        (final.fetchpatch {
          url = "https://raw.githubusercontent.com/chaotic-cx/nyx/refs/heads/main/pkgs/mesa-git/opencl.patch";
          hash = "sha256-pWmkdoA1QkGvXqhy5NMKXN6fPUJJm+9eHW/7p1YIj1k=";
        })
        (final.fetchpatch {
          url = "https://raw.githubusercontent.com/chaotic-cx/nyx/refs/heads/main/pkgs/mesa-git/system-gbm.diff";
          hash = "sha256-JFV63czOLWYw8j7qR0pjIOUH93ZdWP3NQ0/T38HsBIM=";
        })
      ];
    });
  });
}
