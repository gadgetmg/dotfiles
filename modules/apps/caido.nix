{
  flake.modules.nixos.caido = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [caido];
  };
}
