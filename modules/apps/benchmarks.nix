{
  flake.modules.nixos.benchmarks = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      furmark
      kdiskmark
      resources
      vulkan-tools
    ];
  };
}
