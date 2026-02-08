{inputs, ...}: {
  flake.nixosConfigurations.carbon = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ({
        lib,
        pkgs,
        config,
        ...
      }: {
        imports = [
          inputs.disko.nixosModules.disko
          inputs.nix-index-database.nixosModules.nix-index
          inputs.nixos-hardware.nixosModules.common-cpu-amd
          inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
          inputs.nixos-hardware.nixosModules.common-gpu-amd
          inputs.nixos-hardware.nixosModules.common-pc
          inputs.nixos-hardware.nixosModules.common-pc-ssd
          inputs.self.modules.nixos.common
          inputs.self.modules.nixos.sway
          inputs.self.modules.nixos.scx
          inputs.self.modules.nixos.secureboot
          inputs.self.modules.nixos.backups
          inputs.self.modules.nixos.snapshots
          inputs.self.modules.nixos.llama
          inputs.self.modules.nixos.wolf
          inputs.self.modules.nixos.greetd
          inputs.self.modules.nixos.teams
          inputs.self.modules.nixos.libvirt
          inputs.self.modules.nixos.gaming
          inputs.self.modules.nixos.colemak
          inputs.self.modules.nixos.ssh
          inputs.self.modules.nixos.power
          inputs.self.modules.nixos.overclocking
          inputs.self.modules.nixos.wireshark
          inputs.self.modules.nixos.openweathermap
          inputs.self.modules.nixos.zen3
          inputs.self.modules.nixos.desktop
          inputs.self.modules.nixos.shell
          inputs.self.modules.nixos.neovim
          ./_disks.nix
        ];

        boot.kernelModules = ["nct6775"];

        nixpkgs = {
          hostPlatform = "x86_64-linux";
          config.rocmSupport = true;
        };

        virtualisation = {
          docker = {
            enable = true;
            autoPrune.enable = true;
          };
        };

        programs = {
          nix-ld.enable = true;
          firefox.enable = true;
        };

        networking = {
          hostName = "carbon";
          interfaces.enp37s0.wakeOnLan.enable = true;
        };

        time.timeZone = "America/New_York";

        environment = {
          systemPackages = with pkgs; [
            caido
            chezmoi
            chromium
            discord
            furmark
            kdiskmark
            libreoffice-qt-fresh
            llm
            obsidian
            onedrive
            onedrivegui
            python3
            qalculate-qt
            resources
            signal-desktop
            tigervnc
            vulkan-tools
            wineWowPackages.stableFull
            xorg.xrandr
            ymuse
            zathura
            zen
          ];
        };

        users.users."matt" = {
          isNormalUser = true;
          initialPassword = "matt";
          extraGroups = ["docker" "wheel"];
          shell = pkgs.zsh;
        };

        system.stateVersion = "24.11";
      })
    ];
  };
}
