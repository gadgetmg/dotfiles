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
            binPath = lib.getExe' (with pkgs; sway) "sway";
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
      nemo-with-extensions
      networkmanagerapplet
      papirus-icon-theme
      pavucontrol
      playerctl
      pulseaudio
      qalculate-qt
      qt6Packages.qt6ct
      sway
      swaybg
      swayidle
      swaylock
      udiskie
      waybar
      wl-clipboard
      xorg.xrandr
    ];
  };
}
