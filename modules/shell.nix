{inputs, ...}: {
  flake.modules.nixos.shell = {pkgs, ...}: {
    imports = [
      inputs.nix-index-database.nixosModules.nix-index
    ];
    programs = {
      nix-index-database.comma.enable = true;
      zsh.enable = true;
      git.enable = true;
      direnv = {
        enable = true;
        settings = {
          global = {
            disable_stdin = true;
            strict_env = true;
            warn_timeout = 0;
            hide_env_diff = true;
          };
        };
      };
    };

    environment = {
      localBinInPath = true;
      systemPackages = with pkgs; [
        bat
        bind
        btop
        fastfetch
        fzf
        gh
        git
        git-lfs
        htop
        iftop
        iotop
        jc
        jq
        lazygit
        llm
        lm_sensors
        ncmpcpp
        neovim
        nvtopPackages.full
        opencode
        openssl
        pass
        python3
        rclone
        ripgrep
        skim
        starship
        tcpdump
        unzip
        wget
        zellij
        zoxide
      ];
    };
  };
}
