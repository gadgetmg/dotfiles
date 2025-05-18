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
  boot.kernelPackages = pkgs.linuxPackages_testing;

  boot.extraModulePackages = with config.boot.kernelPackages; [ ryzen-smu ];
  boot.kernelModules = [
    "nct6775"
    "vfio_pci"
    "vfio_iommu_type1"
    "vfio"
  ];
  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xfff7ffff"
    "split_lock_detect=off"
  ];
  boot.extraModprobeConfig = "options vfio-pci ids=1002:7550,1002:ab40";

  hardware.amdgpu.opencl.enable = true;
  hardware.enableAllFirmware = true;
  hardware.graphics = with pkgs; {
    package = upstream.mesa;
    package32 = pkgsi686Linux.upstream.mesa;
  };

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
  services.xserver.xkb.variant = "colemak";
  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };
  services.blueman.enable = true;
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
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
    llama-cpp
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
      ryzen-monitor-ng
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
    mesa-stable.configuration = {
      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
      hardware.graphics =
        with pkgs;
        lib.mkForce {
          package = mesa;
          package32 = pkgsi686Linux.mesa;
        };
    };
  };

  system.stateVersion = "24.11";
}
