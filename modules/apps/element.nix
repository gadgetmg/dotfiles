{
  flake.modules.nixos.element = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [element-desktop];
  };
}
