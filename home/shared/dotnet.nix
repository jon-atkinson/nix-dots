{
  pkgs,
  lib,
  mode,
  ...
}:

let
  baseSdk = pkgs.dotnetCorePackages.dotnet_9.sdk;

  msSdkTarball = pkgs.fetchurl {
    url = "https://builds.dotnet.microsoft.com/dotnet/Sdk/9.0.312/dotnet-sdk-9.0.312-linux-x64.tar.gz";
    hash = "sha512-QwqsYdUJsCCtwX8K236Btb6FBG1JeEqy/5J8qRCGJcXN9koOGFoJ3yNMKsHs/q21sQcU8Nm14MH3K1sg++10QA==";
  };

  windowsDesktopSdk = pkgs.runCommand "windows-desktop-sdk" { } ''
    mkdir -p $out
    tar xzf ${msSdkTarball} \
      --wildcards 'sdk/*/Sdks/Microsoft.NET.Sdk.WindowsDesktop/*' \
      -C $out
  '';

  dotnetWithWindowsDesktop = pkgs.symlinkJoin {
    name = "dotnet-sdk-with-windows-desktop";
    paths = [ baseSdk ];
    postBuild = ''
      # Replace the sdk symlink directory with a real copy so we can add to it
      for sdkdir in $out/share/dotnet/sdk/*/Sdks; do
        if [ -L "$sdkdir" ] || [ -d "$sdkdir" ]; then
          real=$(readlink -f "$sdkdir")
          rm -rf "$sdkdir"
          mkdir -p "$sdkdir"
          for item in "$real"/*; do
            ln -s "$item" "$sdkdir/$(basename "$item")"
          done
        fi
      done

      # Copy the WindowsDesktop SDK from the MS tarball
      for sdkdir in $out/share/dotnet/sdk/*/Sdks; do
        for msdir in ${windowsDesktopSdk}/sdk/*/Sdks/Microsoft.NET.Sdk.WindowsDesktop; do
          cp -r "$msdir" "$sdkdir/Microsoft.NET.Sdk.WindowsDesktop"
        done
      done
    '';
  };

  dotnet = if mode == "work" then dotnetWithWindowsDesktop else baseSdk;

in
{
  home.packages = [ dotnet ];
  home.sessionVariables.DOTNET_ROOT = "${dotnet}";
}
