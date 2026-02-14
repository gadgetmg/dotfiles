{
  flake.modules.nixos.teams = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [teams-for-linux];

    services.pipewire.extraConfig.pipewire-pulse = {
      "block-source-volume" = {
        "pulse.rules" = [
          {
            matches = [{"application.process.binary" = "electron";}];
            actions = {quirks = ["block-source-volume"];};
          }
        ];
      };
    };
  };
}
