_: {
  flake.modules.nixos.incus = {pkgs, ...}: {
    virtualisation = {
      incus = {
        enable = true;
        ui.enable = true;
      };
      spiceUSBRedirection.enable = true;
    };
    networking.firewall.trustedInterfaces = ["incusbr0"];
    users.users."matt".extraGroups = ["incus-admin"];
    environment.systemPackages = with pkgs; [
      virt-viewer
    ];
  };
}
