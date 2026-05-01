{inputs, ...}: {
  flake.nixosConfigurations.carbon = inputs.nixpkgs.lib.nixosSystem {
    modules = with inputs.self.modules.nixos; [
      common
      kmscon
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
      mail
      obsidian
      music
      documents
      images
      vnc
      discord
      element
      signal
      onedrive
      benchmarks
      wine
      docker
      rustdesk
      matt
      carbon
    ];
  };

  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    nixpkgsPatcher = {inherit inputs;};
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
