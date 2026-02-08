{inputs, ...}: {
  flake.nixosConfigurations.carbon = inputs.nixpkgs.lib.nixosSystem {
    modules = with inputs.self.modules.nixos; [
      common
      sway
      scx
      secureboot
      backups
      snapshots
      llama
      wolf
      greetd
      teams
      libvirt
      gaming
      colemak
      ssh
      power
      overclock
      wireshark
      openweathermap
      desktop
      shell
      neovim
      caido
      chezmoi
      browsers
      music
      documents
      vnc
      discord
      signal
      onedrive
      benchmarks
      wine
      docker
      matt
      carbon
    ];
  };

  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    modules = with inputs.self.modules.nixos; [
      common
      matt
      shell
      docker
      neovim
      chezmoi
      wsl
    ];
  };
}
