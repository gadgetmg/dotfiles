{
  inputs,
  withSystem,
  ...
}: {
  flake.overlays.upstream = final: prev:
    withSystem prev.stdenv.hostPlatform.system ({
      inputs',
      system,
      ...
    }: let
      trunk = import inputs.trunk config;
      unstable = import inputs.unstable config;
      config = {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      inherit (trunk) caido onedrive;
      inherit (unstable) lact opencode llama-cpp llama-cpp-vulkan llama-swap;
      zen = inputs'.zen-browser.packages.default;
    });
}
