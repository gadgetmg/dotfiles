{
  flake.modules.nixos.kmscon = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [gawk];
    services.kmscon = {
      enable = true;
      package = with pkgs; kmscon;
      config = {
        font-name = "Iosevka Nerd Font";
        hwaccel = true;
      };
    };
  };
}
