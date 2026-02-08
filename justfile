update *INPUTS:
  nix flake update {{INPUTS}}

repl HOST='':
  nixos-rebuild repl --flake .#{{HOST}}

build HOST='':
  nixos-rebuild build --flake .#{{HOST}}

test HOST='':
  sudo nixos-rebuild test --flake .#{{HOST}}

switch HOST='':
  sudo nixos-rebuild switch --flake .#{{HOST}}

boot HOST='':
  sudo nixos-rebuild boot --flake .#{{HOST}}

cleanup:
  sudo nix-collect-garbage -d
