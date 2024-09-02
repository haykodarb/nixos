{
  description = "flutter dev";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.android_sdk.accept_license = true;
        };

        buildInputs = with pkgs; [
          clang
          cmake
          dart
          flutter
          gtk3
          libepoxy
          ninja
          pkg-config

          xorg.libX11.dev
          xorg.libX11
          xorg.libXScrnSaver
          xorg.libXcomposite
          xorg.libXcursor
          xorg.libXdamage
          xorg.libXext
          xorg.libXfixes
          xorg.libXi
          xorg.libXrandr
          xorg.libXrender
          xorg.libXtst
          xorg.libxkbfile
          xorg.libxshmfence

          pcre2

          android-studio
          android-tools

          jdk11

          nodePackages_latest.firebase-tools
        ];

      in {
        devShell =
          pkgs.mkShell
          {
            buildInputs = buildInputs;

            JAVA_HOME = pkgs.jdk11;
            # might be useful
            # ANDROID_AVD_HOME = (toString ./.) + "/.android/avd";
          };
      }
    );
}
