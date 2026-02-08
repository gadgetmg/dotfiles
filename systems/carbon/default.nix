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
          kernelParams = ["mitigations=off" "amdgpu.ppfeaturemask=0xfffd7fff"];
          kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
        };

        hardware = {
          cpu.amd.ryzen-smu.enable = true;
          bluetooth.enable = true;
          enableAllFirmware = true;
        };

        services = {
          wolf.config.uuid = "00a6a114-f021-4f76-bb7a-7d3e5ce35b5b";
          btrfs.autoScrub.enable = true;
          blueman.enable = true;
          lact.enable = true;
          earlyoom.enable = true;
          gvfs.enable = true;
          logind.settings.Login = {
            HandlePowerKey = "ignore";
            HandlePowerKeyLongPress = "poweroff";
            IdleAction = "suspend";
            IdleActionSec = 300;
          };
          openssh.enable = true;
          pipewire.enable = true;
          udisks2 = {
            enable = true;
            mountOnMedia = true;
          };
          printing.enable = true;
          avahi = {
            enable = true;
            nssmdns4 = true;
            openFirewall = true;
          };
          passSecretService.enable = true;
          resolved.enable = true;
        };

        security.rtkit.enable = true;

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
          gnupg.agent.enable = true;
          git.enable = true;
          wireshark.enable = true;
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

        console.keyMap = "colemak";

        time.timeZone = "America/New_York";

        environment = {
          variables = {
            XKB_DEFAULT_LAYOUT = "us";
            XKB_DEFAULT_VARIANT = "colemak";
          };
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
            wireshark
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
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyCuCnOoArBy2Sp1Rx8jOJRGA8436eYt4tpKUcsGmwx gadgetmg@pm.me"
          ];
          extraGroups = ["docker" "networkmanager" "wheel" "wireshark"];
          shell = pkgs.zsh;
        };

        system.stateVersion = "24.11";
      })
    ];
  };
}
