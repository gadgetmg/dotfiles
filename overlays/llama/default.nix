{ channels, inputs, ... }:

final: prev: {
  llama-cpp =
    (prev.llama-cpp.overrideAttrs (
      finalAttrs: prevAttrs: {
        patches = [ ./revert-09d13d9.diff ];
      }
    )).override
      { vulkanSupport = true; };
}
