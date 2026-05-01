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
      inherit (trunk) caido onedrive llama-cpp llama-cpp-vulkan;
      inherit (unstable) opencode llama-swap nixd kmscon;
      zen = inputs'.zen-browser.packages.default;
    });
}
