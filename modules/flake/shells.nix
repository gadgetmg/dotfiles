{
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        nixos-anywhere
        sops
        ssh-to-age
        age
        just
        nixd
      ];
    };
  };
}
