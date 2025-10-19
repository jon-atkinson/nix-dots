{
  pkgs,
  lib,
  mode,
  ...
}:

{
  home.packages = lib.optional (mode == "work") pkgs.codex;
}
