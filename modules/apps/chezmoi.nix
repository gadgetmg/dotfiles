{
  flake.modules.nixos.chezmoi = {pkgs, ...}: {
    environment.systemPackages = [pkgs.chezmoi];
  };
}
