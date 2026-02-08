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
          inputs.self.modules.nixos.common
          inputs.self.modules.nixos.sway
          inputs.disko.nixosModules.disko
          inputs.nixos-hardware.nixosModules.common-cpu-amd
          inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
          inputs.nixos-hardware.nixosModules.common-gpu-amd
          inputs.nixos-hardware.nixosModules.common-pc
          inputs.nixos-hardware.nixosModules.common-pc-ssd
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
            KillUserProcesses = true;
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

        nix.settings.download-buffer-size = 524288000;
        nixpkgs = {
          hostPlatform = "x86_64-linux";
          config.rocmSupport = true;
          overlays = [
            inputs.nix-cachyos-kernel.overlays.pinned
            inputs.self.overlays.kernel-clang
          ];
        };

        virtualisation = {
          docker = {
            enable = true;
            autoPrune.enable = true;
          };
        };

        systemd.user.extraConfig = "DefaultTimeoutStopSec=10s";

        programs = {
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
          dhcpcd.enable = false;
          networkmanager.enable = true;
          firewall.trustedInterfaces = ["virbr0"];
          resolvconf.enable = false;
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
            bind
            git
            git-lfs
            htop
            iftop
            iotop
            jq
            lm_sensors
            nvtopPackages.full
            openssl
            pass
            pavucontrol
            resources
            tcpdump
            unzip
            vulkan-tools
            wget
            wireshark
            xorg.xrandr
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
          packages = with pkgs; [
            bat
            bc
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
            go
            jc
            kdiskmark
            lazygit
            libreoffice-qt-fresh
            llm
            lua5_1
            luarocks
            mangohud
            ncmpcpp
            neovim
            nodejs
            obsidian
            onedrive
            onedrivegui
            opencode
            python3
            qalculate-qt
            rclone
            ripgrep
            signal-desktop
            skim
            starship
            statix
            tigervnc
            wineWowPackages.stableFull
            ymuse
            zathura
            zellij
            zen
            zoxide
          ];
        };

        system.stateVersion = "24.11";
      })
    ];
  };
}
