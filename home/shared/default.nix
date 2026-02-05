{ pkgs, ... }:

{
  home.packages = with pkgs; [
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
    # dotnet-sdk

    # work containerisation
    podman
  ];

  programs.home-manager.enable = true;
  programs.uv.enable = true;
}
