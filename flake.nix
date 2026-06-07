{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-input-patcher.url = "github:jfly/flake-input-patcher";
    import-tree.url = "github:vic/import-tree";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    trunk.url = "github:nixos/nixpkgs/master";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    gadgetmg-pkgs = {
      url = "github:gadgetmg/nix-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs.nixpkgs.follows = "trunk";
    };

    disko = {
      url = "github:nix-community/disko/v1.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
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

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ala-lape = {
      url = "git+https://git.madhouse-project.org/algernon/ala-lape.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = unpatchedInputs: let
    inherit (unpatchedInputs.flake-input-patcher.lib.x86_64-linux) patch fetchpatch;
    inputs = patch {
      inherit unpatchedInputs;
      flakePath = ./.;
      patchSpec = {
        nixpkgs.patches = [
          (fetchpatch {
            name = "nixos/scx-loader: init scx-loader at 1.0.19";
            url = "https://github.com/NixOS/nixpkgs/pull/483360.diff";
            excludes = [
              "nixos/doc/manual/release-notes/rl-2605.section.md"
            ];
            hash = "sha256-zqKukdpxj1zG0eJYp/WCfyIx2wEE40tuWfovSFGOw0A=";
          })
        ];
      };
    };
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree [./modules]);
}
