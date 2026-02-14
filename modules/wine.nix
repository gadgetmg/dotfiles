{
  flake.modules.nixos.wine = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [wineWowPackages.stableFull];
  };
}
