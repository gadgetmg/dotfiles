{inputs, ...}: {
  flake.modules.nixos.gaming = {pkgs, ...}: {
    imports = [
      inputs.nix-gaming.nixosModules.pipewireLowLatency
      inputs.nix-gaming.nixosModules.platformOptimizations
    ];

    services.pipewire.lowLatency.enable = true;

    security.rtkit.enable = true;

    programs = {
      steam = {
        enable = true;
        extest.enable = true;
        platformOptimizations.enable = true;
        protontricks.enable = true;
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        extraPackages = with pkgs; [gamescope];
        gamescopeSession = {
          enable = true;
          args = ["--adaptive-sync"];
        };
      };
      gamescope.enable = true;
      gamemode.enable = true;
    };

    environment.systemPackages = with pkgs; [
      heroic
      mangohud
      protonup-qt
      protonvpn-gui
    ];

    users.users."matt".extraGroups = ["gamemode"];
  };
}
