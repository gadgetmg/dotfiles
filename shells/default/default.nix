{pkgs, ...}:
pkgs.mkShell {
  packages = with pkgs; [
    nixos-anywhere
    sops
    ssh-to-age
    age
    just
  ];
}
