{
  flake.modules.nixos.onedrive = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      onedrive
      onedrivegui
    ];
  };
}
