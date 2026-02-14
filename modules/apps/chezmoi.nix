{
  flake.modules.nixos.chezmoi = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [chezmoi];
  };
}
