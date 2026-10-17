{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-input-patcher.url = "github:jfly/flake-input-patcher";
    import-tree.url = "github:vic/import-tree";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    trunk.url = "github:nixos/nixpkgs/master";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    gadgetmg-pkgs = {
      url = "github:gadgetmg/nix-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/v1.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvirt = {
      url = "github:AshleyYakeley/NixVirt";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming-edge = {
      url = "github:powerofthe69/nix-gaming-edge";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ala-lape = {
      url = "git+https://git.madhouse-project.org/algernon/ala-lape.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wayland-pipewire-idle-inhibit = {
      url = "github:rafaelrc7/wayland-pipewire-idle-inhibit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    substituters = [
      "https://cache.nixos.org/"
      "https://lanzaboote.cachix.org"
      "https://mic92.cachix.org"
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://attic.xuyh0120.win/lantian"
      "https://cache.xinux.uz"
      "https://nix-cache.tokidoki.dev/tokidoki"
    ];
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree [./modules]);
  #   outputs = unpatchedInputs: let
  #     inherit (unpatchedInputs.flake-input-patcher.lib.x86_64-linux) patch fetchpatch;
  #     inputs = patch {
  #       inherit unpatchedInputs;
  #       flakePath = ./.;
  #       patchSpec = {
  #         nixpkgs.patches = [
  #           (fetchpatch {
  #             name = "scx-loader: init at 1.1.1, add nixos module and test";
  #             url = "https://github.com/NixOS/nixpkgs/pull/523462.diff";
  #             excludes = [
  #               "nixos/doc/manual/release-notes/rl-2611.section.md"
  #             ];
  #             hash = "sha256-O1+CkcIrtiYlCaecaXDa92sIz2uvuz3Dg9glnAv6Wpk=";
  #           })
  #         ];
  #       };
  #     };
  #   in
  #     inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree [./modules]);
}
