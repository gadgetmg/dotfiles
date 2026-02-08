{
  flake.modules.nixos.neovim = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      bc
      cargo
      gcc
      go
      lua5_1
      luarocks
      neovim
      nodejs
      statix
    ];
  };
}
