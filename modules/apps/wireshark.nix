{
  flake.modules.nixos.wireshark = {pkgs, ...}: {
    programs.wireshark.enable = true;
    environment.systemPackages = [pkgs.wireshark];
    users.users."matt".extraGroups = ["wireshark"];
  };
}
