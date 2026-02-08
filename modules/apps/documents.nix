{
  flake.modules.nixos.documents = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      libreoffice-qt-fresh
      zathura
    ];
  };
}
