{ lib, package }:
{
  programs.delta = {
    enable = lib.mkEnableOption "the Delta desktop app";

    package = lib.mkOption {
      type = lib.types.package;
      default = package;
      description = "Delta package to install.";
    };
  };
}
