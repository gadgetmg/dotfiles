{
  flake.modules.nixos.vnc = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [tigervnc];
  };
}
