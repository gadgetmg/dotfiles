{inputs, ...}: {
  flake.modules.nixos.sway = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      inputs.wayland-pipewire-idle-inhibit.nixosModules.default
    ];

    programs = {
      sway.enable = true;
      nm-applet.enable = true;
    };

    xdg.portal = {
      extraPortals = with pkgs; [xdg-desktop-portal-luminous];
      config.sway = lib.mkForce {
        default = "gtk";
        "org.freedesktop.impl.portal.ScreenCast" = "luminous";
        "org.freedesktop.impl.portal.ScreenShot" = "luminous";
        "org.freedesktop.impl.portal.RemoteDesktop" = "luminous";
        "org.freedesktop.impl.portal.Settings" = "gtk;luminous";
        "org.freedesktop.impl.portal.Background" = "luminous";
        "org.freedesktop.impl.portal.Clipboard" = "luminous";
        "org.freedesktop.impl.portal.Usb" = "luminous";
      };
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
      displayManager.defaultSession = "sway";
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
      wayland-pipewire-idle-inhibit.enable = true;
    };

    systemd.user = {
      services = {
        windows10spotlight-background = {
          description = "Download and apply Windows 10 Spotlight background to Sway";
          after = ["sway-session.target"];
          wantedBy = ["sway-session.target"];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = lib.getExe pkgs.windows10spotlight-background;
          };
        };
      };
      timers = {
        windows10spotlight-background = {
          description = "Download and apply Windows 10 Spotlight background to Sway";
          wantedBy = ["timers.target"];
          timerConfig = {
            OnCalendar = "hourly";
            Unit = "windows10spotlight-background.service";
            Persistent = true;
          };
        };
      };
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
      xrandr
    ];
  };
}
