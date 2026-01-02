build:
  nixos-rebuild build --flake .

test:
  sudo nixos-rebuild test --flake .

switch:
  sudo nixos-rebuild switch --flake .

boot:
  sudo nixos-rebuild boot --flake .
