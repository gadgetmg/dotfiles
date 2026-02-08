{
  flake.modules.nixos.sway = {
    systemd.user = {
      targets = {
        default.wants = [
          "mpd.service"
        ];
        sway-session.wants = [
          "waybar.service"
          "mako.service"
          "foot-server.socket"
        ];
      };
      services = {
        mpd.wants = [
          "mpDris2.service"
        ];
      };
    };
  };
}
