{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [./disks.nix];

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
    "caddy.env" = {
      group = "caddy";
      mode = "440";
    };
  };

  boot.initrd.systemd.enable = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
  services.scx = {
    enable = true;
    package = pkgs.scx.rustscheds;
    scheduler = "scx_bpfland";
  };

  boot.kernelModules = ["nct6775"];
  boot.kernelParams = ["mitigations=off" "amdgpu.ppfeaturemask=0xfffd7fff"];
  boot.kernelPackages = pkgs.linuxPackages_zen;

  hardware.bluetooth.enable = true;
  hardware.enableAllFirmware = true;
  hardware.graphics.extraPackages = with pkgs; [libvdpau-va-gl];

  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [adwaita-fonts noto-fonts nerd-fonts.iosevka];
  fonts.fontconfig.defaultFonts = {
    sansSerif = ["Noto Sans"];
    serif = ["Noto Serif"];
    monospace = ["Iosevka Nerd Font"];
    emoji = ["Noto Color Emoji"];
  };
  services.btrfs.autoScrub.enable = true;
  services.blueman.enable = true;
  services.caddy = {
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
  services.displayManager.ly.enable = true;
  services.displayManager.defaultSession = "sway";
  services.earlyoom.enable = true;
  services.gvfs.enable = true;
  services.logind.settings.Login.killUserProcesses = true;
  services.openssh.enable = true;
  services.pipewire.enable = true;
  # services.pipewire.lowLatency.enable = true;
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
    settings = let
      llama-server = lib.getExe' pkgs.llama-cpp "llama-server";
    in {
      healthCheckTimeout = 1200;
      macros.llama-server = "${llama-server} --port \${PORT} --jinja";
      models = {
        gpt-oss-20b = {
          cmd = "\${llama-server} -hf ggml-org/gpt-oss-20b-GGUF -ngl 25 -c 131072 --temp 1.0 --top-k 0 --top-p 1.0";
          ttl = 1800;
        };
      };
    };
  };
  services.passSecretService.enable = true;
  services.resolved.enable = true;
  systemd.services.llama-swap.environment.LLAMA_CACHE = "/var/cache/llama-swap";
  systemd.services.llama-swap.serviceConfig.CacheDirectory = "llama-swap";
  nix.settings.download-buffer-size = 524288000;
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
  virtualisation.docker.autoPrune.enable = true;
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers."wolf" = {
    autoStart = true;
    image = "ghcr.io/games-on-whales/wolf:stable";
    environment = {
      "HOST_APPS_STATE_FOLDER" = "/var/lib/wolf";
      "XDG_RUNTIME_DIR" = "/tmp/sockets";
    };
    volumes = [
      "/dev/:/dev:rw"
      "/etc/wolf/:/etc/wolf:rw"
      "/var/lib/wolf/:/var/lib/wolf:rw"
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

  virtualisation.libvirt.connections."qemu:///system" = {
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

  systemd.network.wait-online.enable = false;
  systemd.packages = with pkgs; [lact];
  systemd.services.lactd.wantedBy = ["multi-user.target"];
  systemd.user.extraConfig = "DefaultTimeoutStopSec=10s";
  # Prevents fake graphical session hack since we're correctly integrating sway with systemd
  systemd.user.targets.nixos-fake-graphical-session = lib.mkForce {};

  programs.nix-ld.enable = true;
  programs.zsh.enable = true;
  programs.firefox.enable = true;
  programs.gnupg.agent.enable = true;
  programs.nm-applet.enable = true;
  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.extraPackages = with pkgs; [gamescope];
  programs.steam.gamescopeSession.enable = true;
  programs.steam.gamescopeSession.args = ["--adaptive-sync"];
  programs.gamescope.enable = true;
  programs.ryzen-monitor-ng.enable = true;
  programs.sway.enable = true;
  programs.sway.wrapperFeatures.gtk = true;
  programs.sway.extraSessionCommands = ''
    export WLR_BACKENDS=libinput,drm
    export PROTON_ENABLE_WAYLAND=1
  '';
  programs.git.enable = true;
  programs.gamemode.enable = true;
  programs.gamemode.enableRenice = true;
  programs.virt-manager.enable = true;
  programs.wireshark.enable = true;
  programs.direnv.enable = true;

  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [80 443 47984 47989 48010];
  networking.firewall.allowedUDPPorts = [47999 48010 48100 48200];
  networking.firewall.trustedInterfaces = ["virbr0"];
  networking.resolvconf.enable = false;

  console.keyMap = "colemak";

  time.timeZone = "America/New_York";

  environment.variables.VDPAU_DRIVER = "radeonsi";
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    adwaita-icon-theme-legacy
    adwaita-qt
    adwaita-qt6
    btop-rocm
    papirus-icon-theme
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
    networkmanagerapplet
    nvtopPackages.amd
    pass
    resources
    sbctl
    vulkan-tools
    wireshark
  ];

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
      foot
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
      nemo
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
      zoxide
    ];
  };

  system.stateVersion = "24.11";
}
