{ pkgs, lib, ... }:
{
  imports = [ ./disks.nix ];

  facter.reportPath = ./facter.json;

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets = {
    "secureboot/keys/db/db.key".path = "/etc/secureboot/keys/db/db.key";
    "secureboot/keys/db/db.pem".path = "/etc/secureboot/keys/db/db.pem";
    "secureboot/keys/KEK/KEK.key".path = "/etc/secureboot/keys/KEK/KEK.key";
    "secureboot/keys/KEK/KEK.pem".path = "/etc/secureboot/keys/KEK/KEK.pem";
    "secureboot/keys/PK/PK.key".path = "/etc/secureboot/keys/PK/PK.key";
    "secureboot/keys/PK/PK.pem".path = "/etc/secureboot/keys/PK/PK.pem";
    "secureboot/GUID" = {
      path = "/etc/secureboot/GUID";
      mode = "644";
    };
  };

  boot.lanzaboote = {
    enable = true;
    enrollKeys = true;
    pkiBundle = "/etc/secureboot";
  };

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.extraPackages = with pkgs.kdePackages; [ sddm-kcm ];
  services.openssh.enable = true;
  services.pipewire.enable = true;

  systemd.network.wait-online.enable = false;

  programs.nix-ld.enable = true;
  programs.zsh.enable = true;
  programs.firefox.enable = true;
  programs.steam.enable = true;
  programs.git.enable = true;

  networking.networkmanager.enable = true;

  console.keyMap = "colemak";

  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [ sbctl ];

  users.users."matt" = {
    isNormalUser = true;
    initialPassword = "matt";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyCuCnOoArBy2Sp1Rx8jOJRGA8436eYt4tpKUcsGmwx gadgetmg@pm.me"
    ];
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      cargo
      chezmoi
      discord-canary
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
      starship
      unzip
      wget
      zellij
    ];
  };

  system.stateVersion = "24.11";
}
