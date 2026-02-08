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
          inputs.lanzaboote.nixosModules.lanzaboote
          inputs.nix-gaming.nixosModules.pipewireLowLatency
          inputs.nix-gaming.nixosModules.platformOptimizations
          inputs.nixos-hardware.nixosModules.common-cpu-amd
          inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
          inputs.nixos-hardware.nixosModules.common-gpu-amd
          inputs.nixos-hardware.nixosModules.common-pc
          inputs.nixos-hardware.nixosModules.common-pc-ssd
          inputs.nixvirt.nixosModules.default
          inputs.self.nixosModules.docker-idle-inhibitor
          inputs.self.modules.nixos.scx
          inputs.self.nixosModules.wolf
          ./_disks.nix
        ];

        sops = {
          defaultSopsFile = ./secrets.yaml;
          secrets = {
            "secureboot/keys/db/db.key".path = "/var/lib/sbctl/keys/db/db.key";
            "secureboot/keys/db/db.pem".path = "/var/lib/sbctl/keys/db/db.pem";
            "secureboot/keys/KEK/KEK.key".path = "/var/lib/sbctl/keys/KEK/KEK.key";
            "secureboot/keys/KEK/KEK.pem".path = "/var/lib/sbctl/keys/KEK/KEK.pem";
            "secureboot/keys/PK/PK.key".path = "/var/lib/sbctl/keys/PK/PK.key";
            "secureboot/keys/PK/PK.pem".path = "/var/lib/sbctl/keys/PK/PK.pem";
            "secureboot/GUID" = {
              path = "/var/lib/sbctl/GUID";
              mode = "644";
            };
            "openweathermap.env" = {
              group = "users";
              mode = "440";
            };
            "caddy.env" = {
              group = "caddy";
              mode = "440";
            };
            "restic.env" = {};
          };
        };

        boot = {
          initrd.systemd.enable = true;
          lanzaboote = {
            enable = true;
            pkiBundle = "/var/lib/sbctl";
          };
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
          btrfs.autoScrub.enable = true;
          snapper = {
            snapshotInterval = "minutely";
            configs = let
              defaults = {
                FSTYPE = "btrfs";
                TIMELINE_CREATE = true;
                TIMELINE_CLEANUP = true;
                TIMELINE_LIMIT_HOURLY = 48;
                TIMELINE_LIMIT_DAILY = 7;
              };
            in {
              root = defaults // {SUBVOLUME = "/";};
              home = defaults // {SUBVOLUME = "/home";};
              steam = defaults // {SUBVOLUME = "/opt/steam";};
              heroic = defaults // {SUBVOLUME = "/opt/heroic";};
              roms = defaults // {SUBVOLUME = "/opt/roms";};
            };
          };
          restic.backups.nas = {
            timerConfig = {
              OnCalendar = "05:00";
              Persistent = true;
              WakeSystem = true;
            };
            runCheck = true;
            repository = "s3:https://truenas.lan.seigra.net:9000/restic/carbon";
            paths = [
              "/"
              "/home"
              "/opt/steam/steamapps/compatdata"
              "/opt/roms"
            ];
            extraBackupArgs = ["--verbose" "--one-file-system"];
            inhibitsSleep = true;
            environmentFile = "/run/secrets/restic.env";
            pruneOpts = ["--keep-daily 7"];
          };
          blueman.enable = true;
          caddy = {
            enable = true;
            package = pkgs.caddy.withPlugins {
              plugins = ["github.com/caddy-dns/cloudflare@v0.2.2"];
              hash = "sha256-dnhEjopeA0UiI+XVYHYpsjcEI6Y1Hacbi28hVKYQURg=";
            };
            environmentFile = "/run/secrets/caddy.env";
            globalConfig = ''
              acme_dns cloudflare {env.CF_API_TOKEN}
            '';
            virtualHosts."llama.seigra.net".extraConfig = ''
              reverse_proxy http://localhost:8080
            '';
          };
          greetd = {
            enable = true;
            settings = {
              default_session = let
                greetd-sway-config = pkgs.writeText "greetd-sway-config" ''
                  output 'HP Inc. HP E243d CNC103241L' disable
                  input type:pointer {
                      accel_profile flat
                      pointer_accel 0
                  }
                  seat * hide_cursor when-typing enable
                  exec ${lib.getExe pkgs.swayidle} -w \
                    timeout 30 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
                    idlehint 30
                  exec ${lib.getExe config.programs.regreet.package}; swaymsg exit
                '';
              in {
                command = "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe pkgs.sway} -c ${greetd-sway-config}";
              };
            };
          };
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
          llama-swap = {
            enable = true;
            settings = let
              llama-server = lib.getExe' pkgs.llama-cpp-vulkan "llama-server";
            in {
              healthCheckTimeout = 1200;
              macros.llama-server = "${llama-server} --device Vulkan0 --port \${PORT} --jinja";
              models = {
                gpt-oss-20b = {
                  cmd = "\${llama-server} -hf ggml-org/gpt-oss-20b-GGUF -ngl 25 -c 131072 --temp 1.0 --top-k 0 --top-p 1.0";
                  ttl = 1800;
                };
              };
            };
          };
          passSecretService.enable = true;
          resolved.enable = true;
          wolf = {
            enable = true;
            openFirewall = true;
            config = {
              hostname = "carbon";
              uuid = "00a6a114-f021-4f76-bb7a-7d3e5ce35b5b";
              gstreamer = {
                audio = {
                  default_audio_params = "queue max-size-buffers=3 leaky=downstream ! audiorate ! audioconvert";
                  default_opus_encoder = "opusenc bitrate={bitrate} bitrate-type=cbr frame-size={packet_duration} bandwidth=fullband audio-type=restricted-lowdelay max-payload-size=1400";
                  default_sink = ''
                    rtpmoonlightpay_audio name=moonlight_pay packet_duration={packet_duration} encrypt={encrypt} aes_key="{aes_key}" aes_iv="{aes_iv}" !
                    appsink name=wolf_udp_sink
                  '';
                  default_source = "interpipesrc name=interpipesrc_{}_audio listen-to={session_id}_audio is-live=true stream-sync=restart-ts max-bytes=0 max-buffers=3 block=false";
                };
                video = {
                  default_sink = ''
                    rtpmoonlightpay_video name=moonlight_pay payload_size={payload_size} fec_percentage={fec_percentage} min_required_fec_packets={min_required_fec_packets} !
                    appsink sync=false name=wolf_udp_sink
                  '';
                  default_source = "interpipesrc name=interpipesrc_{}_video listen-to={session_id}_video is-live=true stream-sync=restart-ts max-bytes=0 max-buffers=1 leaky-type=downstream";
                  defaults = {
                    va = {
                      video_params_zero_copy = ''
                        vapostproc add-borders=true !
                        video/x-raw(memory:VAMemory), width={width}, height={height}, pixel-aspect-ratio=1/1
                      '';
                    };
                  };
                  av1_encoders = [
                    {
                      check_elements = ["vaav1enc" "vapostproc"];
                      encoder_pipeline = "vaav1enc ref-frames=1 bitrate={bitrate} cpb-size={bitrate} key-int-max=1024 rate-control=cqp target-usage=2";
                      plugin_name = "va";
                    }
                  ];
                  h264_encoders = [
                    {
                      check_elements = ["vah264enc" "vapostproc"];
                      encoder_pipeline = "vah264enc ref-frames=1 num-slices={slices_per_frame} bitrate={bitrate} cpb-size={bitrate} key-int-max=1024 rate-control=cqp target-usage=2";
                      plugin_name = "va";
                    }
                  ];
                  hevc_encoders = [
                    {
                      check_elements = ["vah265enc" "vapostproc"];
                      encoder_pipeline = "vah265enc ref-frames=1 num-slices={slices_per_frame} bitrate={bitrate} cpb-size={bitrate} key-int-max=1024 rate-control=cqp target-usage=2";
                      plugin_name = "va";
                    }
                  ];
                };
              };
              profiles = [
                {
                  id = "moonlight-profile-id";
                  apps = [
                    {
                      title = "Wolf UI";
                      start_virtual_compositor = true;
                      icon_png_path = "https://raw.githubusercontent.com/games-on-whales/wolf-ui/refs/heads/main/src/Icons/wolf_ui_icon.png";
                      runner = {
                        base_create_json = ''
                          {
                            "HostConfig": {
                              "IpcMode": "host",
                              "CapAdd": ["NET_RAW", "MKNOD", "NET_ADMIN", "SYS_ADMIN", "SYS_NICE"],
                              "Privileged": false,
                              "DeviceCgroupRules": ["c 13:* rmw", "c 244:* rmw"]
                            },
                            "Labels": {
                              "inhibit-sleep": "true"
                            }
                          }
                        '';
                        devices = [];
                        env = [
                          "GOW_REQUIRED_DEVICES=/dev/input/event* /dev/dri/* /dev/nvidia*"
                          "WOLF_SOCKET_PATH=/var/run/wolf/wolf.sock"
                          "WOLF_UI_AUTOUPDATE=False"
                          "LOGLEVEL=INFO"
                        ];
                        image = "ghcr.io/games-on-whales/wolf-ui:main";
                        mounts = [
                          "/var/run/wolf/wolf.sock:/var/run/wolf/wolf.sock"
                        ];
                        name = "Wolf-UI";
                        ports = [];
                        type = "docker";
                      };
                    }
                  ];
                }
                {
                  id = "matt";
                  name = "Matt";
                  apps = [
                    {
                      title = "RetroArch";
                      start_virtual_compositor = true;
                      icon_png_path = "https://games-on-whales.github.io/wildlife/apps/retroarch/assets/icon.png";
                      runner = {
                        base_create_json = ''
                          {
                            "HostConfig": {
                              "IpcMode": "host",
                              "CapAdd": ["NET_RAW", "MKNOD", "NET_ADMIN", "SYS_ADMIN", "SYS_NICE"],
                              "Privileged": false,
                              "DeviceCgroupRules": ["c 13:* rmw", "c 244:* rmw"]
                            }
                          }
                        '';
                        devices = [];
                        env = [
                          "RUN_SWAY=1"
                          "GOW_REQUIRED_DEVICES=/dev/input/* /dev/dri/* /dev/nvidia*"
                        ];
                        image = "ghcr.io/games-on-whales/retroarch:edge";
                        mounts = ["/opt/roms:/mnt:ro"];
                        name = "WolfRetroarch";
                        ports = [];
                        type = "docker";
                      };
                    }
                    {
                      start_virtual_compositor = true;
                      title = "Steam";
                      icon_png_path = "https://games-on-whales.github.io/wildlife/apps/steam/assets/icon.png";
                      runner = {
                        base_create_json = ''
                          {
                            "HostConfig": {
                              "IpcMode": "host",
                              "CapAdd": ["SYS_ADMIN", "SYS_NICE", "SYS_PTRACE", "NET_RAW", "MKNOD", "NET_ADMIN"],
                              "SecurityOpt": ["seccomp=unconfined", "apparmor=unconfined"],
                              "Ulimits": [{"Name":"nofile", "Hard":10240, "Soft":10240}],
                              "Privileged": false,
                              "DeviceCgroupRules": ["c 13:* rmw", "c 244:* rmw"]
                            }
                          }
                        '';
                        devices = [];
                        env = [];
                        image = "ghcr.io/gadgetmg/steam:sway";
                        mounts = ["/opt/steam/steamapps:/home/retro/.local/share/Steam/steamapps:rw"];
                        name = "WolfSteam";
                        ports = [];
                        type = "docker";
                      };
                    }
                    {
                      title = "Heroic";
                      start_virtual_compositor = true;
                      icon_png_path = "https://games-on-whales.github.io/wildlife/apps/heroic-games-launcher/assets/icon.png";
                      runner = {
                        base_create_json = ''
                          {
                            "HostConfig": {
                              "IpcMode": "host",
                              "CapAdd": ["SYS_ADMIN", "SYS_NICE", "SYS_PTRACE", "NET_RAW", "MKNOD", "NET_ADMIN"],
                              "SecurityOpt": ["seccomp=unconfined", "apparmor=unconfined"],
                              "Ulimits": [{"Name":"nofile", "Hard":10240, "Soft":10240}],
                              "Privileged": false,
                              "DeviceCgroupRules": ["c 13:* rmw", "c 244:* rmw"]
                            }
                          }
                        '';
                        devices = [];
                        env = [
                          "RUN_SWAY=1"
                          "GOW_REQUIRED_DEVICES=/dev/input/* /dev/dri/* /dev/nvidia*"
                        ];
                        image = "ghcr.io/games-on-whales/heroic-games-launcher:edge";
                        mounts = ["/opt/heroic:/home/retro/Games/Heroic:rw"];
                        name = "WolfHeroic";
                        ports = [];
                        type = "docker";
                      };
                    }
                  ];
                }
              ];
            };
          };
          docker-idle-inhibitor.enable = true;
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

        systemd = {
          # Configure cache directory for llama.cpp (via llama-swap) to download internet models
          services.llama-swap = {
            environment.LLAMA_CACHE = "/var/cache/llama-swap";
            serviceConfig.CacheDirectory = "llama-swap";
          };
          user.extraConfig = "DefaultTimeoutStopSec=10s";
        };

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
          regreet = {
            enable = true;
            settings = {
              GTK.application_prefer_dark_theme = true;
              widget.clock.format = "%I:%M%p";
            };
            theme = {
              name = "catppuccin-mocha-lavender-standard";
              package = pkgs.catppuccin-gtk;
            };
            font = {
              name = "Noto Sans";
              package = pkgs.noto-fonts;
            };
            iconTheme = {
              name = "Papirus-Dark";
              package = pkgs.papirus-icon-theme;
            };
          };
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
          firewall = {
            allowedTCPPorts = [80 443]; # caddy
            trustedInterfaces = ["virbr0"];
          };
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
