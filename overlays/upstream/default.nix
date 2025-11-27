{
  channels,
  inputs,
  ...
}: final: prev: {
  inherit (channels.trunk) caido llama-swap onedrive;
  inherit (channels.unstable) lact;
  llama-cpp = inputs.llama-cpp.packages.${prev.system}.vulkan;
  opencode = inputs.opencode.packages.${prev.system}.default;
}
