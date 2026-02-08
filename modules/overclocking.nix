{
  flake.modules.nixos.overclocking = {pkgs, ...}: {
    boot.kernelParams = ["amdgpu.ppfeaturemask=0xfffd7fff"];
    hardware.cpu.amd.ryzen-smu.enable = true;
    services.lact.enable = true;
  };
}
