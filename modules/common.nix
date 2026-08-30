{withSystem, ...}: {
  flake.modules.nixos.common = {config, ...}: {
    nixpkgs.pkgs = withSystem config.nixpkgs.hostPlatform.system ({pkgs, ...}: pkgs);
    nix = {
      channel.enable = false;
      settings = {
        experimental-features = ["nix-command" "flakes"];
        accept-flake-config = true;
        auto-optimise-store = true;
        download-buffer-size = 1073741824;
      };
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 7d";
      };
    };
  };
}
