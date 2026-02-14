{inputs, ...}: {
  imports = [inputs.flake-parts.flakeModules.modules];
  debug = true;
  perSystem = {system, ...}: {
    _module.args.pkgs = import (inputs.nixpkgs-patcher.lib.patchNixpkgs {inherit inputs system;}) {
      inherit system;
      config = {
        allowUnfree = true;
        rocmSupport = true;
      };
      overlays = [
        inputs.nix-cachyos-kernel.overlays.pinned
        inputs.ala-lape.overlays.default
        inputs.self.overlays.kernel-lto-patches
        inputs.self.overlays.overrides
        inputs.self.overlays.scx
        inputs.self.overlays.upstream
      ];
    };
  };
}
