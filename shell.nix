{ pkgs ? import <nixpkgs> { } }:
let
  connectiq = pkgs.callPackage ./connectiq.nix { };
in
pkgs.mkShell {
  buildInputs = [
    connectiq
  ];
}
