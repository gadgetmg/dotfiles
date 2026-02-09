{inputs, ...}: {
  flake.modules.nixos.common = {config, ...}: {
    nixpkgs = {
      config.allowUnfree = true;
      overlays = [
        inputs.nix-cachyos-kernel.overlays.pinned
        inputs.ala-lape.overlays.default
        inputs.self.overlays.kernel-lto-patches
        inputs.self.overlays.overrides
        inputs.self.overlays.scx
        inputs.self.overlays.upstream
      ];
    };

    nix = {
      channel.enable = false;
      settings = {
        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = true;
        download-buffer-size = 1073741824;
        substituters = [
          "https://lanzaboote.cachix.org"
          "https://mic92.cachix.org"
          "https://nix-community.cachix.org"
          "https://nix-gaming.cachix.org"
          "https://cache.garnix.io"
          "https://attic.xuyh0120.win/lantian"
        ];
        trusted-public-keys = [
          "lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="
          "mic92.cachix.org-1:gi8IhgiT3CYZnJsaW7fxznzTkMUOn1RY4GmXdT/nXYQ="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        ];
      };
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 7d";
      };
    };
  };
}
