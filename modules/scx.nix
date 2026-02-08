{inputs, ...}: {
  flake.modules.nixos.scx = {pkgs, ...}: {
    imports = [
      inputs.self.nixosModules.scx-loader
    ];

    nixpkgs.overlays = [
      inputs.self.overlays.scx
    ];

    services.scx_loader = {
      enable = true;
      default_sched = "scx_cake";
    };

    users.users."matt".extraGroups = ["scx"];
  };
}
