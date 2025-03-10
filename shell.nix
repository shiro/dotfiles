{ pkgs ? import <nixpkgs> { } }:

let
  rust_overlay = import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz");
  pkgs = import <nixpkgs> { overlays = [ rust_overlay ]; };
  rust = pkgs.rust-bin.nightly."2025-03-10".default.override {
    extensions = [ "rust-src" ];
  };
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [ upx ];
  buildInputs = [
    rust
  ] ++ (with pkgs; [
    pkg-config
  ]);
  RUST_BACKTRACE = 1;
}
