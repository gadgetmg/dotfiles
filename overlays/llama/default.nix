{
  channels,
  inputs,
  ...
}: final: prev: {
  llama-cpp =
    (prev.llama-cpp.overrideAttrs (
      finalAttrs: prevAttrs: {
        patches = [./fix-409284.patch];
      }
    )).override
    {vulkanSupport = true;};
}
