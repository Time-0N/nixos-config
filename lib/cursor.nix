{ pkgs }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "macosx-cursor-moyash";
  version = "1.0";

  src = ../assets/cursor/MacOSX-Cursor.zip;
  nativeBuildInputs = [ pkgs.unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons/MacOSX-Cursor
    cp -r MacOSX/. $out/share/icons/MacOSX-Cursor/

    substituteInPlace $out/share/icons/MacOSX-Cursor/index.theme \
      --replace-fail "Name=MacOSX" "Name=MacOSX-Cursor"

    runHook postInstall
  '';

  meta = {
    description = "MacOSX cursor theme, vendored in assets/cursor";
    platforms = pkgs.lib.platforms.all;
  };
}
