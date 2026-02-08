{
  flake.modules.nixos.overclocking = {pkgs, ...}: {
    boot.kernelParams = ["amdgpu.ppfeaturemask=0xfffd7fff"];
    services.lact.enable = true;
  };
}
