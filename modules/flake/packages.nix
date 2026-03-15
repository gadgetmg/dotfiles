{
  inputs,
  withSystem,
  ...
}: {
  imports = [inputs.pkgs-by-name-for-flake-parts.flakeModule];
  perSystem = _: {
    pkgsDirectory = ../../pkgs;
  };
  flake.overlays.default = final: prev:
    withSystem prev.stdenv.hostPlatform.system (
      {config, ...}: config.packages
    );
}
