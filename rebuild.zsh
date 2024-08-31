#!/usr/bin/env zsh
set -e
pushd ~/nixos
nvim ~/nixos
git diff -U0 
echo "NixOS Rebuilding"
sudo nixos-rebuild switch | (&> output.log) | tail -n 5 output.log || (cat output.log | grep --color error && false)
gen=$(nixos-rebuild list-generations | grep current)
git commit -am "$gen"
git push
popd
