{
  channels,
  inputs,
  ...
}: final: prev: {
  inherit (channels.trunk) caido onedrive;
  inherit (channels.unstable) lact opencode llama-cpp llama-cpp-vulkan llama-swap;
  zen = inputs.zen-browser.packages.${prev.stdenv.hostPlatform.system}.default;
}
