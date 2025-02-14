{ pkgs, ... }:
{
  programs.nix-ld.enable = true;
  programs.zsh.enable = true;
  programs.git.enable = true;

  virtualisation.docker.enable = true;

  users.users."nixos" = {
    isNormalUser = true;
    initialPassword = "nixos";
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      cargo
      chezmoi
      foot
      fzf
      gcc
      git
      lazygit
      lua5_1
      luarocks
      neovim
      nixfmt-rfc-style
      nodejs
      ripgrep
      skim
      starship
      unzip
      wget
      zellij
    ];
  };

  system.stateVersion = "24.11";
}
