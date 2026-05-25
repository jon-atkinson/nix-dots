{ pkgs, ... }:

{
  imports = [ ./dotnet.nix ];

  home.packages = with pkgs; [
    age
    sops
    zip
    xz
    unzip
    ripgrep
    fzf
    iperf3
    nmap
    which
    nix-output-monitor
    lsof
    usbutils
    gh
    curl
    wget
    htop
    fd
    tree
    rlwrap

    # formatters
    gofumpt
    nodePackages.prettier
    stylua
    ruff
    nixfmt-rfc-style

    # language toolchains
    rustup
    maven
    go

    # work containerisation
    podman
    
    # work clipboard util
    xclip

    # compression libs 
    zlib
    snappy
    lz4
    zstd
  ];

  targets.genericLinux.enable = pkgs.stdenv.isLinux;
  programs.home-manager.enable = true;
  programs.uv.enable = true;
}
