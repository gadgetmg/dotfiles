{
  flake.modules.nixos.matt = {pkgs, ...}: {
    # nix.settings.trusted-users = ["matt"];
    users.users."matt" = {
      isNormalUser = true;
      initialPassword = "matt";
      extraGroups = ["wheel"];
      shell = with pkgs; zsh;
    };
  };
}
