{ channels, inputs, ... }:

final: prev: {
  linux-firmware = prev.linux-firmware.overrideAttrs (_: {
    version = builtins.substring 0 (builtins.stringLength prev.linux-firmware.version) inputs.linux-firmware.rev;
    src = inputs.linux-firmware;
  });
}
