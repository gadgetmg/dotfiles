{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    trunk.url = "github:nixos/nixpkgs/master";

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

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs.nixpkgs.follows = "unstable";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ala-lape = {
      url = "git+https://git.madhouse-project.org/algernon/ala-lape.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    systems = [
      "x86_64-linux"
    ];
    forEachSystem = pkgs: lib.genAttrs systems (system: pkgs pkgsFor.${system});
    pkgsFor = lib.genAttrs systems (
      system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
    );
  in {
    devShells = forEachSystem (pkgs: {
      default = import ./shells/default {inherit pkgs;};
    });
    packages = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});
    formatter = forEachSystem (pkgs: pkgs.alejandra);
    overlays = import ./overlays {inherit inputs;};
    nixosModules = import ./modules/nixos;
    nixosConfigurations = let
      commonModules = [
        inputs.nix-index-database.nixosModules.nix-index
        {
          programs.nix-index-database.comma.enable = true;
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = builtins.attrValues self.overlays;
          nix = {
            channel.enable = false;
            settings = {
              auto-optimise-store = true;
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
              options = "--delete-older-than 30d";
            };
          };
        }
      ];
    in {
      carbon = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules =
          commonModules
          ++ [
            inputs.disko.nixosModules.disko
            inputs.lanzaboote.nixosModules.lanzaboote
            inputs.nix-gaming.nixosModules.pipewireLowLatency
            inputs.nix-gaming.nixosModules.platformOptimizations
            inputs.nixos-hardware.nixosModules.common-cpu-amd
            inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
            inputs.nixos-hardware.nixosModules.common-gpu-amd
            inputs.nixos-hardware.nixosModules.common-pc
            inputs.nixos-hardware.nixosModules.common-pc-ssd
            inputs.nixvirt.nixosModules.default
            inputs.sops-nix.nixosModules.sops
            self.nixosModules.docker-idle-inhibitor
            self.nixosModules.scx-loader
            self.nixosModules.wolf
            ./systems/carbon
          ];
      };
      wsl = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules =
          commonModules
          // [
            inputs.nixos-wsl.nixosModules.default
            {wsl.enable = true;}
            ./systems/wsl
          ];
      };
    };
  };
}
