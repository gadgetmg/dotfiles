{
  flake.modules.nixos.signal = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [signal-desktop];
  };
}
