{
  flake.modules.nixos.discord = {pkgs, ...}: {
    environment.systemPackages = [pkgs.discord];
  };
}
