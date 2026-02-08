{
  flake.modules.nixos.browsers = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      chromium
      zen
    ];
  };
}
