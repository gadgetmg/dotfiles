{
  channels,
  inputs,
  ...
}: final: prev: {
  llama-cpp = inputs.llama-cpp.packages.${prev.system}.vulkan;
}
