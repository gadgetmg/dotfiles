{inputs, ...}: {
  flake.nixosConfigurations.carbon = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ({
        lib,
        pkgs,
        config,
        ...
      }: {
        imports = [
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
          inputs.nix-index-database.nixosModules.nix-index
          inputs.nixos-hardware.nixosModules.common-cpu-amd
          inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
          inputs.nixos-hardware.nixosModules.common-gpu-amd
          inputs.nixos-hardware.nixosModules.common-pc
          inputs.nixos-hardware.nixosModules.common-pc-ssd
          inputs.self.modules.nixos.common
          inputs.self.modules.nixos.sway
          inputs.self.modules.nixos.scx
          inputs.self.modules.nixos.secureboot
          inputs.self.modules.nixos.backups
          inputs.self.modules.nixos.snapshots
          inputs.self.modules.nixos.llama
          inputs.self.modules.nixos.wolf
          inputs.self.modules.nixos.greetd
          inputs.self.modules.nixos.teams
          inputs.self.modules.nixos.libvirt
          inputs.self.modules.nixos.gaming
          inputs.self.modules.nixos.sessions
          inputs.self.modules.nixos.colemak
          inputs.self.modules.nixos.ssh
          inputs.self.modules.nixos.power
          inputs.self.modules.nixos.overclocking
          inputs.self.modules.nixos.wireshark
          ./_disks.nix
        ];

        sops = {
          defaultSopsFile = ./secrets.yaml;
          secrets = {
            "openweathermap.env" = {
              group = "users";
              mode = "440";
            };
          };
        };

        boot = {
          initrd.systemd.enable = true;
          kernelModules = ["nct6775"];
          kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
        };

        hardware = {
          bluetooth.enable = true;
          enableAllFirmware = true;
        };

        services = {
          earlyoom.enable = true;
          resolved.enable = true;
        };

        nixpkgs = {
          hostPlatform = "x86_64-linux";
          config.rocmSupport = true;
        };

        virtualisation = {
          docker = {
            enable = true;
            autoPrune.enable = true;
          };
        };

        programs = {
          nix-index-database.comma.enable = true;
          nix-ld.enable = true;
          zsh.enable = true;
          firefox.enable = true;
          git.enable = true;
          direnv = {
            enable = true;
            settings = {
              global = {
                disable_stdin = true;
                strict_env = true;
                warn_timeout = 0;
                hide_env_diff = true;
              };
            };
          };
        };

        networking = {
          hostName = "carbon";
          networkmanager.enable = true;
          interfaces.enp37s0.wakeOnLan.enable = true;
        };

        time.timeZone = "America/New_York";

        environment = {
          localBinInPath = true;
          systemPackages = with pkgs; [
            bat
            bc
            bind
            btop
            caido
            cargo
            chezmoi
            chromium
            discord
            fastfetch
            furmark
            fzf
            gcc
            gh
            git
            git-lfs
            go
            htop
            iftop
            iotop
            jc
            jq
            kdiskmark
            lazygit
            libreoffice-qt-fresh
            llm
            lm_sensors
            lua5_1
            luarocks
            ncmpcpp
            neovim
            nodejs
            nvtopPackages.full
            obsidian
            onedrive
            onedrivegui
            opencode
            openssl
            pass
            python3
            qalculate-qt
            rclone
            resources
            ripgrep
            signal-desktop
            skim
            starship
            statix
            tcpdump
            tigervnc
            unzip
            vulkan-tools
            wget
            wineWowPackages.stableFull
            xorg.xrandr
            ymuse
            zathura
            zellij
            zen
            zoxide
          ];
        };

        users.users."matt" = {
          isNormalUser = true;
          initialPassword = "matt";
          extraGroups = ["docker" "networkmanager" "wheel"];
          shell = pkgs.zsh;
        };

        system.stateVersion = "24.11";
      })
    ];
  };
}
