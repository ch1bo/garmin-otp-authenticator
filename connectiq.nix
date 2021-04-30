{ lib
, stdenv
, fetchurl
, makeWrapper
, runCommand
, unzip
, jre
  # libraries used by SDK binaries
, atk
, cairo
, expat
, freetype
, gdk-pixbuf
, glib
, gnome2
, fontconfig
, libjpeg
, libpng
, libSM
, libsoup
, libudev
, libusb
, libXxf86vm
, pango
, xorg
, zlib
}:
let
  rpath = lib.makeLibraryPath [
    atk
    cairo
    expat
    freetype
    gdk-pixbuf
    glib
    gnome2.gtk
    fontconfig
    libpng
    libSM
    libsoup
    libudev
    libusb
    libXxf86vm
    linkedLibjpeg
    pango
    xorg.libX11
    xorg.libXext
    zlib
  ] + ":${stdenv.cc.cc.lib}/lib64";

  binaries = [
    "$out/bin/shell"
    "$out/bin/simulator"
  ];

  oldWebkitgtk = (import
    (builtins.fetchTarball {
      name = "nixpkgs-for-libwebkitgtk-1.0";
      url = "https://github.com/nixos/nixpkgs/archive/989711d6f46fe71cb76510194885c1e03c215253.tar.gz";
      sha256 = "156wr9h7sjlhz6mqrbnpjk3fb0sy9084hkm0nz65j5w97k72r37l";
    })
    { }).webkitgtk24x-gtk2;

  linkedLibjpeg = runCommand libjpeg.name
    {
      propagatedBuildInputs = [ libjpeg ];
    }
    ''
      mkdir -p $out/lib
      ln -s ${libjpeg.out}/lib/libjpeg.so.62.3.0 $out/lib/libjpeg.so.8
    '';
in
stdenv.mkDerivation rec {
  pname = "connectiq-sdk";
  version = "3.2.5-2021-02-12-6d31f4357";

  src = fetchurl {
    url = "https://developer.garmin.com/downloads/connect-iq/sdks/connectiq-sdk-lin-${version}.zip";
    sha256 = "9vV4HMUqC3st3NB3G3cMcTMHLiIq4dHiOFWrcSZts3c=";
  };

  nativeBuildInputs = [
    # wrapGAppsHook
    # glib # For setup hook populating GSETTINGS_SCHEMA_PATH
    unzip # For unpacking
    makeWrapper
  ];

  buildInputs = [ jre ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    unzip $src -d $out

    # Otherwise it looks "suspicious"
    chmod -R g-w $out

    # Use our own wrapper
    makeWrapper ${jre}/bin/java $out/bin/monkeyc \
      --add-flags "-cp $out/bin/monkeybrains.jar com.garmin.monkeybrains.Monkeybrains"

    # Add a default.jungle file
    cp ${./default.jungle} $out/bin/default.jungle
  '';

  postFixup = ''
    for file in ${builtins.concatStringsSep " " binaries}; do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
      patchelf --set-rpath ${rpath} $file || true
    done
  '';

  meta = with lib; {
    description = "Connect IQ SDK";
    homepage = "https://developer.garmin.com/connect-iq/sdk/";
    license = licenses.unfree; # TODO(SN)
    maintainers = with lib.maintainers; [ ];
    platforms = [ "x86_64-linux" ];
  };
}
