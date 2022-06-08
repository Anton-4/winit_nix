{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-21.11";
    naersk.url = "github:nix-community/naersk";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    naersk,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        linuxInputs = with pkgs; [
            libxkbcommon
            libGL
            xorg.libXcursor
            xorg.libXrandr
            xorg.libXi
            xorg.libX11
          ];

        naersk-lib = naersk.lib."${system}";
      in rec {

        # nix build
          packages.winit_nix = naersk-lib.buildPackage {
            pname = "winit_nix";
            root = ./.;
            buildInputs = linuxInputs;
            nativeBuildInputs = with pkgs; [
              pkg-config
              makeWrapper # to be able to use wrapProgram
            ];
            postInstall = ''
              wrapProgram $out/bin/winit_nix --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath linuxInputs}"
             '';
          };

          defaultPackage = packages.winit_nix;
      });
}
