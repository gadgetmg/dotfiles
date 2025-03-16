{ channels, inputs, ... }:

final: prev: {
  inherit (channels.trunk) linuxPackages_zen;
}
