{
  flake.modules.nixos.wine = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [wineWow64Packages.stableFull];
  };
}
