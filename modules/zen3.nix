{
  flake.modules.nixos.zen3 = {pkgs, ...}: {
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
    hardware.cpu.amd.ryzen-smu.enable = true;
  };
}
