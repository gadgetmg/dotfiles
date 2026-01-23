{inputs, ...}: {
  default = final: prev:
    import ../pkgs {inherit (final) pkgs;}
    // {
      scx = (prev.scx or {}) // import ../pkgs/scx {inherit (final) pkgs;};
    };

  upstream = import ./upstream {inherit inputs;};
  kernel-clang = import ./kernel-clang {};
  overrides = import ./overrides {};
  scx = import ./scx {};
  cachyos = inputs.nix-cachyos-kernel.overlays.pinned;
  ala-lape = inputs.ala-lape.overlays.default;
}
