with import <nixpkgs> {};
with pkgs;

stdenv.mkDerivation rec {
  pname = "mictray";
  version = "0.2.5";

  src = ./.;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook
  ];

  buildInputs = [
    gtk3
    libgee
    libnotify
    libpulseaudio
    keybinder3
  ];

  doCheck = true;
}
