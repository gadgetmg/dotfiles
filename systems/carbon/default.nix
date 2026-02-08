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
          inputs.nix-gaming.nixosModules.pipewireLowLatency
          inputs.nix-gaming.nixosModules.platformOptimizations
          inputs.nixos-hardware.nixosModules.common-cpu-amd
          inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
          inputs.nixos-hardware.nixosModules.common-gpu-amd
          inputs.nixos-hardware.nixosModules.common-pc
          inputs.nixos-hardware.nixosModules.common-pc-ssd
          inputs.nixvirt.nixosModules.default
          inputs.self.modules.nixos.scx
          inputs.self.modules.nixos.secureboot
          inputs.self.modules.nixos.backups
          inputs.self.modules.nixos.snapshots
          inputs.self.modules.nixos.llama
          inputs.self.modules.nixos.wolf
          inputs.self.modules.nixos.greetd
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

        fonts = {
          enableDefaultPackages = true;
          packages = with pkgs; [adwaita-fonts roboto roboto-serif noto-fonts nerd-fonts.iosevka];
          fontconfig.defaultFonts = {
            sansSerif = ["Roboto Condensed"];
            serif = ["Roboto Serif"];
            monospace = ["Iosevka Nerd Font"];
            emoji = ["Noto Color Emoji"];
          };
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
          pipewire = {
            enable = true;
            lowLatency.enable = true;
            extraConfig.pipewire-pulse = {
              "block-source-volume" = {
                "pulse.rules" = [
                  {
                    matches = [{"application.process.binary" = "electron";}];
                    actions = {quirks = ["block-source-volume"];};
                  }
                ];
              };
            };
          };
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

        security = {
          rtkit.enable = true;
          pam.mount = {
            enable = true;
            extraVolumes = [
              # Mount shared game libraries into home directories
              ''<volume fstype="none" path="/opt/steam/steamapps" mountpoint="~/.local/share/Steam/steamapps" options="bind" />''
              ''<volume fstype="none" path="/opt/heroic" mountpoint="~/Games/Heroic" options="bind" />''
              ''<volume fstype="none" path="/opt/roms" mountpoint="~/Games/ROMs" options="bind" />''
            ];
          };
        };

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
            storageDriver = "btrfs";
            autoPrune.enable = true;
          };
          libvirtd.enable = true;
          libvirt = {
            swtpm.enable = true;
            connections."qemu:///system" = {
              pools = [
                {
                  definition = inputs.nixvirt.lib.pool.writeXML {
                    name = "default";
                    uuid = "f0e6f7ac-1743-4a6d-a039-0ef1d72c78f7";
                    type = "dir";
                    target = {path = "/var/lib/libvirt/images";};
                  };
                  active = true;
                }
              ];
              networks = [
                {
                  definition = inputs.nixvirt.lib.network.writeXML {
                    name = "default";
                    uuid = "704742fd-87cc-4391-aaf0-1ac32fb1a951";
                    forward = {
                      mode = "nat";
                      nat = {
                        port = {
                          start = 1024;
                          end = 65535;
                        };
                      };
                    };
                    bridge = {name = "virbr0";};
                    mac = {address = "52:54:00:e3:f5:2d";};
                    ip = {
                      address = "192.168.74.1";
                      netmask = "255.255.255.0";
                      dhcp = {
                        range = {
                          start = "192.168.74.2";
                          end = "192.168.74.254";
                        };
                      };
                    };
                  };
                  active = true;
                }
              ];
            };
          };
        };

        systemd.user.extraConfig = "DefaultTimeoutStopSec=10s";

        programs = {
          nix-ld.enable = true;
          zsh.enable = true;
          firefox.enable = true;
          gnupg.agent.enable = true;
          nm-applet.enable = true;
          steam = {
            enable = true;
            extest.enable = true;
            platformOptimizations.enable = true;
            protontricks.enable = true;
            remotePlay.openFirewall = true;
            localNetworkGameTransfers.openFirewall = true;
            extraPackages = with pkgs; [gamescope];
            gamescopeSession = {
              enable = true;
              args = ["--adaptive-sync"];
            };
          };
          gamescope.enable = true;
          git.enable = true;
          gamemode.enable = true;
          virt-manager.enable = true;
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
            adwaita-icon-theme
            adwaita-icon-theme-legacy
            bind
            file-roller
            git
            git-lfs
            grim
            htop
            iftop
            iotop
            jq
            lm_sensors
            nemo-with-extensions
            networkmanagerapplet
            nvtopPackages.full
            openssl
            pass
            pavucontrol
            pulseaudio
            resources
            sbctl
            tcpdump
            udiskie
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
          extraGroups = ["docker" "networkmanager" "wheel" "wireshark" "libvirtd" "gamemode"];
          shell = pkgs.zsh;
          packages = with pkgs; [
            ala-lape
            app2unit
            bat
            bc
            btop
            caido
            cargo
            catppuccin-gtk
            chezmoi
            chromium
            darkly
            dex
            discord
            fastfetch
            furmark
            fzf
            gcc
            gh
            go
            heroic
            jc
            kanshi
            kdiskmark
            lazygit
            libreoffice-qt-fresh
            llm
            lua5_1
            luarocks
            mako
            mangohud
            ncmpcpp
            neovim
            nodejs
            obsidian
            onedrive
            onedrivegui
            opencode
            papirus-icon-theme
            playerctl
            protonup-qt
            protonvpn-gui
            python3
            qalculate-qt
            qt6Packages.qt6ct
            rclone
            ripgrep
            signal-desktop
            skim
            starship
            statix
            swaybg
            teams-for-linux
            tigervnc
            wineWowPackages.stableFull
            wl-clipboard
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
