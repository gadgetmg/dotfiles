{
  flake.modules.nixos.greetd = {
    config,
    pkgs,
    lib,
    ...
  }: {
    programs.regreet = {
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

    services.greetd = {
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
  };
}
