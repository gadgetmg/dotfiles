{
  flake.modules.nixos.documents = {pkgs, ...}: {
    fonts.packages = with pkgs; [liberation_ttf carlito caladea];

    environment.systemPackages = with pkgs; [
      libreoffice-qt-fresh
      zathura
    ];
  };
}
