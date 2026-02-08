{
  flake.modules.nixos.overclock = {
    boot.kernelParams = ["amdgpu.ppfeaturemask=0xfffd7fff"];
    services.lact.enable = true;
  };
}
