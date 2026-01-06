update *INPUTS:
  nix flake update {{INPUTS}}

build:
  nixos-rebuild build --flake .

test:
  sudo nixos-rebuild test --flake .

switch:
  sudo nixos-rebuild switch --flake .

boot:
  sudo nixos-rebuild boot --flake .

cleanup:
  sudo nix-collect-garbage -d
