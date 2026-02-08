{
  flake.modules.nixos.vnc = {pkgs, ...}: {
    environment.systemPackages = [pkgs.tigervnc];
  };
}
