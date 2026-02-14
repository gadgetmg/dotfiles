{
  flake.modules.nixos.kmscon = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [gawk];
    services.kmscon = {
      enable = true;
      hwRender = true;
      package = with pkgs; kmscon;
      fonts = [
        {
          name = "Iosevka Nerd Font";
          package = with pkgs; nerd-fonts.iosevka;
        }
      ];
    };
  };
}
