{
  flake.modules.nixos.caido = {pkgs, ...}: {
    environment.systemPackages = [pkgs.caido];
  };
}
