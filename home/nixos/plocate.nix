{ pkgs, lib, ... }:

{
  home.packages =
    with pkgs;
    pkgs.lib.optionals pkgs.stdenv.isLinux [
      plocate
    ];
  services.plocate = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    updateInterval = "daily";
  };
}
