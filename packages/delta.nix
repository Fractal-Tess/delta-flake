{
  lib,
  stdenv,
  requireFile,
  autoPatchelfHook,
  makeWrapper,
  fontconfig,
  libGL,
  openssl,
  wayland,
  vulkan-loader,
}:

let
  pname = "delta";
  version = "0.16.1";
  asset = "delta-linux-x86_64.tar.gz";
in
stdenv.mkDerivation {
  inherit pname version;

  src = requireFile {
    name = asset;
    hash = "sha256-+G91zPV+3UYF7OxVEhJcQgd6HHA67c7/WQNxSp6oB4Y=";
    message = ''
      Delta downloads require an authenticated Zed account.

      1. Download the Linux x86_64 archive from https://delta.dev/download
      2. Add it to the Nix store:
         nix-store --add-fixed sha256 delta-linux-x86_64.tar.gz
    '';
  };

  sourceRoot = "Delta";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    fontconfig
    libGL
    openssl
    stdenv.cc.cc.lib
    wayland
    vulkan-loader
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/delta" "$out/bin" "$out/share"
    cp -a bin lib "$out/lib/delta/"
    cp -a share/. "$out/share/"

    ln -s "$out/lib/delta/bin/delta" "$out/bin/delta"

    substituteInPlace "$out/share/applications/dev.zed.Delta.desktop" \
      --replace-fail "Exec=delta cli open %U" "Exec=$out/bin/delta cli open %U"

    runHook postInstall
  '';

  postFixup = ''
    patchelf "$out/lib/delta/bin/delta" --add-rpath ${
      lib.makeLibraryPath [
        fontconfig
        libGL
        openssl
        wayland
        vulkan-loader
      ]
    }
    wrapProgram "$out/lib/delta/bin/delta" \
      --prefix XDG_DATA_DIRS : "$out/share"
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    version_output="$($out/bin/delta --version)"
    test "$version_output" = "delta ${version}"
    test -f "$out/share/applications/dev.zed.Delta.desktop"
    runHook postInstallCheck
  '';

  meta = {
    description = "Multiplayer environment for coding with agents and reviewing their work";
    homepage = "https://delta.dev";
    downloadPage = "https://delta.dev/download";
    license = lib.licenses.unfree;
    mainProgram = "delta";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}
