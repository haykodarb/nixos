#!/usr/bin/env zsh
set -e
pushd ~/nixos
nvim ~/nixos
git diff -U0 
echo "NixOS Rebuilding"
sudo nixos-rebuild switch &> nixos-switch.log || (cat nixos-switch.log | grep --color error && false)
gen=$(nixos-rebuild list-generations | grep current)
git commit -am "$gen"
git push
popd
