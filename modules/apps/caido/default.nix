{
  flake.modules.nixos.caido = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [caido];
    security.pki.certificates = [(builtins.readFile ./ca.crt)];
  };
}
