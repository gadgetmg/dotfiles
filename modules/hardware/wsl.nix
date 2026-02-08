{inputs, ...}: {
  flake.modules.nixos.wsl = {
    imports = [
      inputs.nixos-wsl.nixosModules.default
    ];
    wsl.enable = true;
    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "24.11";
  };
}
