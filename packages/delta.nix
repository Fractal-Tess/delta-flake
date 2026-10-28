{
  lib,
  symlinkJoin,
  libxau,
  libxdmcp,
  upstream,
}:
let
  # Upstream's bundled libxcb needs these libraries too. Keep its full linkage
  # check enabled and supply the missing paths before that check runs.
  patched = upstream.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      find "$out/opt/delta" -type f -print0 |
      while IFS= read -r -d "" elf; do
        if patchelf --print-rpath "$elf" >/dev/null 2>&1; then
          patchelf --add-rpath "${
            lib.makeLibraryPath [
              libxau
              libxdmcp
            ]
          }" "$elf"
        fi
      done
    '';
  });
in
# Preserve the existing command name while using Zed's maintained binary package.
symlinkJoin {
  name = "delta-${upstream.version}";
  paths = [ patched ];
  postBuild = ''
    ln -s delta "$out/bin/zed-delta"
  '';
  passthru.version = upstream.version;
  meta = upstream.meta // {
    mainProgram = "zed-delta";
  };
}
