{
  flake.modules.nixos.overclock = _: {
    boot.kernelParams = ["amdgpu.ppfeaturemask=0xfffd7fff"];
    services.lact.enable = true;
  };
}
