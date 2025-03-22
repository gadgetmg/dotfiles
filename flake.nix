{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    linux-firmware = {
      url = "git+https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
      flake = false;
    };

    mesa = {
      url = "git+https://gitlab.freedesktop.org/mesa/mesa.git";
      flake = false;
    };

    snowfall-lib = {
      url = "github:snowfallorg/lib/v3.0.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/v1.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming.url = "github:fufexan/nix-gaming";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
  };

  outputs =
    inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;
      channels-config = {
        allowUnfree = true;
      };

      systems.modules.nixos = with inputs; [
        nix-index-database.nixosModules.nix-index
        {
          programs.nix-index-database.comma.enable = true;
          nix.channel.enable = false;
          nix.settings = {
            substituters = [
              "https://lanzaboote.cachix.org"
              "https://mic92.cachix.org"
              "https://nix-community.cachix.org"
              "https://nix-gaming.cachix.org"
              "https://jovian.cachix.org"
            ];
            trusted-public-keys = [
              "lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="
              "mic92.cachix.org-1:gi8IhgiT3CYZnJsaW7fxznzTkMUOn1RY4GmXdT/nXYQ="
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
              "jovian.cachix.org-1:8Vq4Txku6VZIRhYrHYki3Ab9XHJRoWmdYqMqj4rB/Uc="
            ];
          };
          nix.settings.auto-optimise-store = true;
          nix.gc = {
            automatic = true;
            dates = "daily";
            options = "--delete-older-than 30d";
          };
        }
      ];

      systems.hosts.carbon.modules = with inputs; [
        disko.nixosModules.disko
        jovian.nixosModules.default
        lanzaboote.nixosModules.lanzaboote
        nix-gaming.nixosModules.pipewireLowLatency
        nix-gaming.nixosModules.platformOptimizations
        nixos-facter-modules.nixosModules.facter
        nixos-hardware.nixosModules.common-cpu-amd
        nixos-hardware.nixosModules.common-cpu-amd-pstate
        nixos-hardware.nixosModules.common-gpu-amd
        nixos-hardware.nixosModules.common-pc
        nixos-hardware.nixosModules.common-pc-ssd
        sops-nix.nixosModules.sops
      ];

      systems.hosts.wsl.modules = with inputs; [
        nixos-wsl.nixosModules.default
        { wsl.enable = true; }
      ];
    };
}
