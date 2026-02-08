add:
  git add --intent-to-add .

update *INPUTS:
  nix flake update {{INPUTS}}

repl HOST='': add
  nixos-rebuild repl --flake .#{{HOST}}

build HOST='': add
  nixos-rebuild build --flake .#{{HOST}}

test HOST='': add
  sudo nixos-rebuild test --flake .#{{HOST}}

switch HOST='': add
  sudo nixos-rebuild switch --flake .#{{HOST}}

boot HOST='': add
  sudo nixos-rebuild boot --flake .#{{HOST}}

cleanup:
  sudo nix-collect-garbage -d
