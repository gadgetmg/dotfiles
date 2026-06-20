{
  flake.modules.nixos.protonvpn = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [proton-vpn];
  };
}
