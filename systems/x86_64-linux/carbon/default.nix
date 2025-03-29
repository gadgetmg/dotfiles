{ config, pkgs, ... }:
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
  };

  boot.loader.systemd-boot.memtest86.enable = true;
  boot.initrd.systemd.enable = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
  boot.kernelPackages = pkgs.linuxPackages_testing;
  boot.extraModulePackages = with config.boot.kernelPackages; [ ryzen-smu ];
  boot.kernelModules = [ "nct6775" ];
  boot.kernelParams = [ "amdgpu.ppfeaturemask=0xfff7ffff" ];

  hardware.amdgpu.amdvlk = {
    enable = true;
    support32Bit.enable = true;
    supportExperimental.enable = true;
  };
  hardware.amdgpu.opencl.enable = true;
  hardware.enableAllFirmware = true;
  hardware.graphics = with pkgs; {
    package = upstream.mesa;
    package32 = pkgsi686Linux.upstream.mesa;
  };
  system.replaceDependencies.replacements = with pkgs; [
    {
      oldDependency = mesa.out;
      newDependency = upstream.mesa.out;
    }
    {
      oldDependency = pkgsi686Linux.mesa.out;
      newDependency = pkgsi686Linux.upstream.mesa.out;
    }
  ];

  jovian.steam.enable = true;
  jovian.steam.user = "matt";
  jovian.steamos.useSteamOSConfig = false;
  jovian.hardware.has.amd.gpu = true;

  services.btrfs.autoScrub.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "plasma";
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

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  systemd.network.wait-online.enable = false;
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];
  systemd.extraConfig = ''DefaultTimeoutStopSec=10s'';
  systemd.user.extraConfig = ''DefaultTimeoutStopSec=10s'';

  programs.nix-ld.enable = true;
  programs.zsh.enable = true;
  programs.firefox.enable = true;
  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.platformOptimizations.enable = true;
  programs.steam.extraPackages = with pkgs; [ gamescope ];
  programs.git.enable = true;
  programs.gamemode.enable = true;
  programs.gamemode.enableRenice = true;

  networking.networkmanager.enable = true;

  console.keyMap = "colemak";

  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
    btop-rocm
    furmark
    git
    git-lfs
    heroic
    htop
    iftop
    iotop
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
      cargo
      chezmoi
      direnv
      discord
      emacs
      foot
      fzf
      gcc
      gh
      lazygit
      lua5_1
      luarocks
      mangohud
      neovim
      nixfmt-rfc-style
      nodejs
      openssl
      ripgrep
      ryzen-monitor-ng
      skim
      starship
      tcpdump
      tigervnc
      unzip
      wget
      wineWowPackages.stableFull
      wireshark
      wl-clipboard
      zellij
    ];
  };

  system.stateVersion = "24.11";
}
