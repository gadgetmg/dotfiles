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
    };
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
    environment.systemPackages = with pkgs; [
      foot
      fuzzel
      mpd
      mpdris2
      sway
      swayidle
      swaylock
      waybar
    ];
  };
}
