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
      # unstable = import inputs.unstable config;
      config = {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      inherit (trunk) caido onedrive;
      # inherit (unstable) opencode llama-swap nixd kmscon qemu virt-manager;
      zen = inputs'.zen-browser.packages.default;

      llama-cpp = trunk.llama-cpp-vulkan;
      # llama-cpp = (trunk.llama-cpp.overrideAttrs
      #   (previousAttrs: {
      #     patches =
      #       (previousAttrs.patches or [])
      #       ++ [
      #         (final.fetchpatch {
      #           url = "https://github.com/ggml-org/llama.cpp/pull/28243.patch";
      #           hash = "sha256-4NfwObukSL4l6ljrm85Apsy4QC06u7D9S54ML8QAIEM=";
      #         })
      #       ];
      #   })).override {vulkanSupport = true;};
    });
}
