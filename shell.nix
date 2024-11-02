{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell { 
    nativeBuildInputs = with pkgs; [ rustc cargo gcc upx ];

    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
}

