{
  flake.modules.nixos.music = {pkgs, ...}: {
    systemd.user.targets.default.wants = [
      "mpd.socket"
      "mpDris2.service"
    ];
    environment.systemPackages = with pkgs; [
      mpc
      mpd
      mpdris2
      ymuse
    ];
  };
}
