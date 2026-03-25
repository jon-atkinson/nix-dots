{
  pkgs,
  mode,
  ...
}:

let
  baseSdk = pkgs.dotnetCorePackages.dotnet_9.sdk;

  msSdk = pkgs.stdenv.mkDerivation {
    name = "dotnet-sdk-ms-9.0.312";
    src = pkgs.fetchurl {
      url = "https://builds.dotnet.microsoft.com/dotnet/Sdk/9.0.312/dotnet-sdk-9.0.312-linux-x64.tar.gz";
      hash = "sha512-QwqsYdUJsCCtwX8K236Btb6FBG1JeEqy/5J8qRCGJcXN9koOGFoJ3yNMKsHs/q21sQcU8Nm14MH3K1sg++10QA==";
    };
    sourceRoot = ".";
    unpackPhase = ''
      mkdir -p $out
      tar xzf $src -C $out
    '';
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin
      ln -s $out/dotnet $out/bin/dotnet
    '';
  };

  dotnet = if mode == "work" then msSdk else baseSdk;

in
{
  home.packages = [ dotnet ];
  home.sessionVariables.DOTNET_ROOT = "${dotnet}";
}
