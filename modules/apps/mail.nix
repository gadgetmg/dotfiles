{
  flake.modules.nixos.mail = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [thunderbird];
    services.protonmail-bridge.enable = true;
  };
}
