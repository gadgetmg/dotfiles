{inputs, ...}: final: prev: let
  trunk = import inputs.trunk config;
  unstable = import inputs.unstable config;
  config = {
    inherit (prev.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in {
  inherit (trunk) caido onedrive;
  inherit (unstable) lact opencode llama-cpp llama-cpp-vulkan llama-swap;
  zen = inputs.zen-browser.packages.${prev.stdenv.hostPlatform.system}.default;
}
