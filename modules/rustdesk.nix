{
  flake.modules.nixos.rustdesk = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [rustdesk-flutter];
  };
}
