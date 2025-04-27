{
  config,
  lib,
  pkgs,
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
  boot.kernelPackages = pkgs.linuxPackagesFor (
    pkgs.linux_testing.override {
      argsOverride = rec {
        src = pkgs.fetchurl {
          url = "https://git.kernel.org/torvalds/t/linux-${version}.tar.gz";
          sha256 = "sha256-Ntokx3v/cuyLXfMEypL7GWy5O8KiAwwH0hJJBaNbLaI=";
        };
        version = "6.15-rc3";
        modDirVersion = "6.15.0-rc3";
      };
    }
  );

  boot.extraModulePackages = with config.boot.kernelPackages; [ ryzen-smu ];
  boot.kernelModules = [ "nct6775" ];
  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xfff7ffff"
    "split_lock_detect=off"
  ];

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
  services.sunshine.enable = true;
  services.sunshine.openFirewall = true;
  services.sunshine.capSysAdmin = true;
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
  programs.steam.platformOptimizations.enable = true;
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
