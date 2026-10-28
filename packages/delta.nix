{ symlinkJoin, upstream }:
# Preserve the existing command name while using Zed's maintained binary package.
symlinkJoin {
  name = "delta-${upstream.version}";
  paths = [ upstream ];
  postBuild = ''
    ln -s delta "$out/bin/zed-delta"
  '';
  passthru.version = upstream.version;
  meta = upstream.meta // {
    mainProgram = "zed-delta";
  };
}
