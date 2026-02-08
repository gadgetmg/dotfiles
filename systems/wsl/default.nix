{inputs, ...}: {
  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ({pkgs, ...}: {
        imports = [
          inputs.self.modules.nixos.common
          inputs.nixos-wsl.nixosModules.default
        ];
        wsl.enable = true;

        nixpkgs.hostPlatform = "x86_64-linux";

        programs = {
          nix-ld.enable = true;
          zsh.enable = true;
          git.enable = true;
        };

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
      })
    ];
  };
}
