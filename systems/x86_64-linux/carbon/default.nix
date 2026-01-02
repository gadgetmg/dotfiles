{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [./disks.nix];

  facter.reportPath = ./facter.json;

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
    graphics.extraPackages = with pkgs; [libvdpau-va-gl];
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [adwaita-fonts noto-fonts nerd-fonts.iosevka];
    fontconfig.defaultFonts = {
      sansSerif = ["Noto Sans"];
      serif = ["Noto Serif"];
      monospace = ["Iosevka Nerd Font"];
      emoji = ["Noto Color Emoji"];
    };
  };

  services = {
    btrfs.autoScrub.enable = true;
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
    displayManager = {
      ly = {
        enable = true;
        settings = {
          allow_empty_password = false;
          clear_password = true;
          vi_mode = true;
          vi_default_mode = "insert";
          login_cmd = "/etc/ly/login.sh";
        };
      };
      defaultSession = "sway";
    };
    scx = {
      enable = true;
      package = pkgs.scx.rustscheds;
      scheduler = "scx_bpfland";
    };
    lact.enable = true;
    earlyoom.enable = true;
    gvfs.enable = true;
    logind.settings.Login = {
      KillUserProcesses = true;
      HandlePowerKey = "ignore";
      HandlePowerKeyLongPress = "poweroff";
    };
    openssh.enable = true;
    pipewire = {
      enable = true;
      lowLatency.enable = true;
    };
    xserver.xkb.variant = "colemak";
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
                    "RUN_GAMESCOPE=true"
                    "GOW_REQUIRED_DEVICES=/dev/input/* /dev/dri/* /dev/nvidia*"
                  ];
                  image = "ghcr.io/games-on-whales/retroarch:edge";
                  mounts = ["/home/matt/Games/ROMs:/mnt:ro"];
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
                  env = [
                    "PROTON_LOG=1"
                    "RUN_GAMESCOPE=true"
                    "GOW_REQUIRED_DEVICES=/dev/input/* /dev/dri/* /dev/nvidia*"
                  ];
                  image = "ghcr.io/games-on-whales/steam:edge";
                  mounts = ["/home/matt/.steam/steam/steamapps:/home/retro/.steam/steam/steamapps:rw"];
                  name = "WolfSteam";
                  ports = [];
                  type = "docker";
                };
              }
              {
                title = "Lutris";
                start_virtual_compositor = true;
                icon_png_path = "https://games-on-whales.github.io/wildlife/apps/lutris/assets/icon.png";
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
                    "RUN_GAMESCOPE=1"
                    "GOW_REQUIRED_DEVICES=/dev/input/event* /dev/dri/* /dev/nvidia* /var/lutris/"
                  ];
                  image = "ghcr.io/games-on-whales/lutris:edge";
                  mounts = ["lutris:/var/lutris/:rw"];
                  name = "WolfLutris";
                  ports = [];
                  type = "docker";
                };
              }
            ];
          }
        ];
      };
    };
  };

  security.rtkit.enable = true;

  nix.settings.download-buffer-size = 524288000;

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
    user = {
      extraConfig = "DefaultTimeoutStopSec=10s";
      # Prevents fake graphical session hack since we're correctly integrating sway with systemd
      targets.nixos-fake-graphical-session = lib.mkForce {};
    };
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
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
    git.enable = true;
    gamemode = {
      enable = true;
      enableRenice = true;
    };
    virt-manager.enable = true;
    wireshark.enable = true;
    direnv.enable = true;
  };

  networking = {
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
    etc."ly/login.sh".mode = "0755";
    etc."ly/login.sh".text = ''
      while read -r l; do
          eval export $l
      done < <(${pkgs.systemd}/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
      exec "$@"
    '';
    variables.VDPAU_DRIVER = "radeonsi";
    localBinInPath = true;
    systemPackages = with pkgs; [
      adwaita-icon-theme
      adwaita-icon-theme-legacy
      adwaita-qt
      adwaita-qt6
      btop-rocm
      furmark
      git
      git-lfs
      heroic
      htop
      iftop
      iotop
      jq
      libreoffice
      lm_sensors
      networkmanagerapplet
      nvtopPackages.amd
      papirus-icon-theme
      pass
      resources
      sbctl
      vulkan-tools
      wireshark
    ];
  };

  users.users."matt" = {
    isNormalUser = true;
    initialPassword = "matt";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyCuCnOoArBy2Sp1Rx8jOJRGA8436eYt4tpKUcsGmwx gadgetmg@pm.me"
    ];
    extraGroups = ["docker" "networkmanager" "wheel" "wireshark" "libvirtd"];
    shell = pkgs.zsh;
    packages = with pkgs; [
      (catppuccin-gtk.override {variant = "mocha";})
      bat
      bc
      bind
      caido
      cargo
      chezmoi
      chromium
      dex
      file-roller
      foot
      fuzzel
      fzf
      gcc
      gh
      go
      jc
      kanshi
      kdiskmark
      lazygit
      llm
      lua5_1
      luarocks
      mako
      mangohud
      ncmpcpp
      nemo-with-extensions
      neovim
      nodejs
      nwg-look
      obsidian
      onedrive
      onedrivegui
      opencode
      openssl
      pavucontrol
      playerctl
      protonup-qt
      protonvpn-gui
      python3
      qalculate-gtk
      rclone
      ripgrep
      skim
      starship
      statix
      swaybg
      tcpdump
      tigervnc
      udiskie
      unzip
      vesktop
      waybar
      wayland-pipewire-idle-inhibit
      wget
      wineWowPackages.stableFull
      wl-clipboard
      xorg.xrandr
      zathura
      zellij
      zen
      zoxide
    ];
  };

  system.stateVersion = "24.11";
}
