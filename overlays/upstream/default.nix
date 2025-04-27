{ channels, inputs, ... }:

final: prev: with final; {
  upstream = lib.makeScope newScope (_: {
    mesa = prev.mesa.overrideAttrs (_: {
      version = builtins.substring 0 (builtins.stringLength prev.mesa.version) inputs.mesa.rev;
      src = inputs.mesa;
      patches = [
        ./opencl.patch
      ];
    });
  });
}
