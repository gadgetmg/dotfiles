{
  flake.modules.nixos.caido = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [caido-desktop caido-cli];
    security.pki.certificates = [(builtins.readFile ./ca.crt)];
  };
}
