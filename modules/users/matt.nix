{
  flake.modules.nixos.matt = {pkgs, ...}: {
    users.users."matt" = {
      isNormalUser = true;
      initialPassword = "matt";
      extraGroups = ["wheel"];
      shell = pkgs.zsh;
    };
  };
}
