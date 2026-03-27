{
  flake.modules.nixos.images = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      gimp-with-plugins
      inkscape
    ];
  };
}
