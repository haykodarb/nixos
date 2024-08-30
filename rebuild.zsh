!/usr/bin/env zsh
set -e
pushd ~/nixos
nvim ./user/home.nix
alejandra . &>/dev/null
git diff -U0 *.nix 
echo "NixOS Rebuilding"
sudo nixos-rebuild switch &> nixos-switch.log || (cat nixos-switch.log | grep --color error && false)
gen=$(nixos-rebuild list-generations | grep current)
git commit -am "$gen"
popd
