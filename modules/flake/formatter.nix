{
  perSystem = {pkgs, ...}: {
    formatter = with pkgs; alejandra;
  };
}
