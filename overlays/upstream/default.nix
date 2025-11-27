{
  channels,
  inputs,
  ...
}: final: prev: {
  inherit (channels.trunk) caido llama-swap onedrive;
  inherit (channels.unstable) lact;
  llama-cpp = inputs.llama-cpp.packages.${prev.stdenv.hostPlatform.system}.vulkan;
  opencode = inputs.opencode.packages.${prev.stdenv.hostPlatform.system}.default;
}
