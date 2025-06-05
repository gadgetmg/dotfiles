{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ ./disks.nix ];

  facter.reportPath = ./facter.json;

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets = {
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
  };

  boot.initrd.systemd.enable = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
  boot.kernelPackages = pkgs.linuxPackages_cachyos-lto;
  services.scx.loader = {
    enable = true;
    config = {
      default_mode = "Auto";
    };
  };

  # TODO: incompatible with lto kernel
  # boot.extraModulePackages = with config.boot.kernelPackages; [ ryzen-smu ];
  #

  boot.kernelModules = [
    "nct6775"
  ];
  boot.kernelParams = [
    "mitigations=off"
  ];

  hardware.amdgpu.opencl.enable = true;
  hardware.enableAllFirmware = true;

  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    adwaita-fonts
    noto-fonts
    nerd-fonts.iosevka
  ];
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Noto Sans" ];
    serif = [ "Noto Serif" ];
    monospace = [ "Iosevka Nerd Font" ];
    emoji = [ "Noto Color Emoji" ];
  };
  services.btrfs.autoScrub.enable = true;
  services.displayManager.ly.enable = true;
  services.displayManager.defaultSession = "sway";
  services.logind.killUserProcesses = true;
  services.netdata.enable = true;
  services.netdata.configDir."go.d/sensors.conf" = pkgs.writeText "sensors.conf" ''
    jobs:
      - name: sensors
        binary_path: ${pkgs.lm_sensors}/bin/sensors
  '';
  services.netdata.package = pkgs.netdata.override {
    withCloudUi = true;
  };
  services.onedrive.enable = true;
  services.openssh.enable = true;
  services.pipewire.enable = true;
  services.pipewire.lowLatency.enable = true;
  security.rtkit.enable = true;
  services.xserver.xkb.variant = "colemak";
  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.llama-swap = {
    enable = true;
    port = 8081;
    package = pkgs.internal.llama-swap;
    config = {
      healthCheckTimeout = 600;
      models = {
        DeepSeek-R1-0528-Qwen3-8B = {
          cmd = "llama-server --port \${PORT} -ngl 999 -fa -hf unsloth/DeepSeek-R1-0528-Qwen3-8B-GGUF:Q4_K_XL --ctx-size 51200 --jinja --temp 0.6 --top-k 20 --top-p 0.95 --min-p 0 --predict 32768";
          ttl = 60;
        };
        gemma-3-12b-it-qat = {
          cmd = "llama-server --port \${PORT} -ngl 999 -fa -hf unsloth/gemma-3-12b-it-qat-GGUF:Q4_K_XL --ctx-size 17408 --temp 1.0 --repeat-penalty 1.0 --min-p 0.01 --top-k 64 --top-p 0.95";
          ttl = 60;
        };
        gemma-3-27b-it-qat = {
          cmd = "llama-server --port \${PORT} -ngl 999 -fa -hf unsloth/gemma-3-27b-it-qat-GGUF:IQ3_XXS --ctx-size 16384 --temp 1.0 --repeat-penalty 1.0 --min-p 0.01 --top-k 64 --top-p 0.95";
          ttl = 60;
        };
      };
    };
  };
  services.open-webui.enable = true;
  nix.settings.download-buffer-size = 524288000;
  systemd.user.services.mopidy = {
    enable = true;
    description = "Mopidy";
    wantedBy = [ "default.target" ];
    script =
      let
        mopidy-with-extensions =
          with pkgs;
          buildEnv {
            name = "mopidy-with-extensions-${mopidy.version}";
            meta.mainProgram = "mopidy";
            ignoreCollisions = true;
            paths = lib.closePropagation [
              mopidy-mpris
              mopidy-somafm
              mopidy-mpd
              internal.mopidy-autoplay
            ];
            pathsToLink = [ "/${mopidyPackages.python.sitePackages}" ];
            nativeBuildInputs = [ makeWrapper ];
            postBuild = ''
              makeWrapper ${lib.getExe mopidy} $out/bin/mopidy \
                --prefix PYTHONPATH : $out/${mopidyPackages.python.sitePackages}
            '';
          };
      in
      "${lib.getExe mopidy-with-extensions}";
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
  virtualisation.docker.autoPrune.enable = true;
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers."wolf" = {
    autoStart = true;
    image = "ghcr.io/games-on-whales/wolf:stable";
    environment = {
      "HOST_APPS_STATE_FOLDER" = "/etc/wolf";
      "XDG_RUNTIME_DIR" = "/tmp/sockets";
    };
    volumes = [
      "/dev/:/dev:rw"
      "/etc/wolf/:/etc/wolf:rw"
      "/run/udev:/run/udev:rw"
      "/tmp/sockets:/tmp/sockets:rw"
      "/var/run/docker.sock:/var/run/docker.sock:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--device=/dev/dri:/dev/dri:rwm"
      "--device=/dev/uhid:/dev/uhid:rwm"
      "--device=/dev/uinput:/dev/uinput:rwm"
      "--network=host"
    ];
  };
  virtualisation.libvirt.enable = true;
  virtualisation.libvirt.swtpm.enable = true;
  virtualisation.libvirtd.qemu.ovmf.packages = [
    (pkgs.OVMFFull.override { msVarsTemplate = true; }).fd
  ];

  virtualisation.libvirt.connections."qemu:///system" = {
    pools = [
      {
        definition = inputs.nixvirt.lib.pool.writeXML {
          name = "default";
          uuid = "f0e6f7ac-1743-4a6d-a039-0ef1d72c78f7";
          type = "dir";
          target = {
            path = "/var/lib/libvirt/images";
          };
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
          bridge = {
            name = "virbr0";
          };
          mac = {
            address = "52:54:00:e3:f5:2d";
          };
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
    domains = [
      { definition = ./windows-11.xml; }
      { definition = ./windows-11-qxl.xml; }
    ];
  };

  systemd.network.wait-online.enable = false;
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];
  systemd.extraConfig = ''DefaultTimeoutStopSec=10s'';
  systemd.user.extraConfig = ''DefaultTimeoutStopSec=10s'';

  programs.nix-ld.enable = true;
  programs.zsh.enable = true;
  programs.chromium.enable = true;
  programs.firefox.enable = true;
  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.extraPackages = with pkgs; [ gamescope ];
  programs.steam.gamescopeSession.enable = true;
  programs.steam.gamescopeSession.args = [ "--adaptive-sync" ];
  programs.gamescope.enable = true;
  programs.sway.enable = true;
  programs.sway.wrapperFeatures.gtk = true;
  programs.sway.extraPackages =
    with pkgs;
    lib.mkOptionDefault [
      i3status-rust
      kanshi
      dex
      xorg.xrandr
      mako
      udiskie
      wayland-pipewire-idle-inhibit
      blueberry
      pavucontrol
    ];
  programs.git.enable = true;
  programs.gamemode.enable = true;
  programs.gamemode.enableRenice = true;

  networking.networkmanager.enable = true;

  console.keyMap = "colemak";

  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
    adwaita-qt
    adwaita-qt6
    adwaita-icon-theme
    adwaita-icon-theme-legacy
    btop-rocm
    furmark
    git
    git-lfs
    heroic
    htop
    iftop
    iotop
    jq
    lact
    libreoffice
    lm_sensors
    nvtopPackages.amd
    resources
    sbctl
    unigine-heaven
    unigine-superposition
    unigine-valley
    virt-manager
    vulkan-tools
  ];

  environment.variables = {
    PROTON_ENABLE_WAYLAND = "1";
  };

  users.users."matt" = {
    isNormalUser = true;
    initialPassword = "matt";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyCuCnOoArBy2Sp1Rx8jOJRGA8436eYt4tpKUcsGmwx gadgetmg@pm.me"
    ];
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
      "wireshark"
      "libvirtd"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      bat
      bind
      (catppuccin-gtk.override { variant = "mocha"; })
      cargo
      chezmoi
      direnv
      discord
      foot
      fzf
      gcc
      gh
      kdiskmark
      lazygit
      lua5_1
      luarocks
      mangohud
      nemo
      ncmpcpp
      neovim
      nixfmt-rfc-style
      nodejs
      nwg-look
      openssl
      protonup-qt
      ripgrep
      # ryzen-monitor-ng
      skim
      starship
      swaybg
      tcpdump
      tigervnc
      unzip
      wget
      wineWowPackages.stableFull
      wireshark
      wl-clipboard
      ymuse
      zellij
    ];
  };

  specialisation = {
    mesa-git.configuration = {
      hardware.graphics = with pkgs; {
        package = upstream.mesa;
        package32 = pkgsi686Linux.upstream.mesa;
      };
    };
  };

  system.stateVersion = "24.11";
}
