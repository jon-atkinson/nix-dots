{ pkgs, ... }:

let
  zlib32 = pkgs.pkgsi686Linux.zlib;

  q32 = pkgs.writeShellScriptBin "q32" ''
    export QHOME=$HOME/q32
    export LD_LIBRARY_PATH=${zlib32}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
    exec ${pkgs.rlwrap}/bin/rlwrap -r $HOME/q32/l32/q "$@"
  '';
in
{
  home.packages = [ q32 ];
}
