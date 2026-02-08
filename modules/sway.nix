{
  flake.modules.nixos.sway = {
    pkgs,
    lib,
    ...
  }: {
    services.displayManager.defaultSession = "sway-uwsm";

    programs = {
      sway = {
        enable = true;
        package = null;
      };
      uwsm = {
        enable = true;
        waylandCompositors = {
          sway = {
            prettyName = "Sway";
            comment = "Sway compositor managed by UWSM";
            binPath = lib.getExe' pkgs.sway "sway";
          };
        };
      };
      nm-applet.enable = true;
      gnupg.agent.enable = true;
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
      blueman.enable = true;
      gvfs.enable = true;
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
    };

    systemd.user = {
      targets = {
        default.wants = [
          "mpd.socket"
          "mpDris2.service"
        ];
        sway-session.wants = [
          "waybar.service"
          "mako.service"
          "foot-server.socket"
        ];
      };
    };

    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
      adwaita-icon-theme-legacy
      ala-lape
      app2unit
      catppuccin-gtk
      darkly
      dex
      file-roller
      foot
      fuzzel
      grim
      kanshi
      mako
      mpd
      mpdris2
      nemo-with-extensions
      networkmanagerapplet
      papirus-icon-theme
      pavucontrol
      playerctl
      pulseaudio
      qt6Packages.qt6ct
      sway
      swaybg
      swayidle
      swaylock
      udiskie
      waybar
      wl-clipboard
    ];
  };
}
