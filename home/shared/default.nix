{ pkgs, lib, ... }:

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
    rustup

    # formatters
    gofumpt
    nodePackages.prettier
    stylua
    ruff
    nixfmt-rfc-style
  ];

  programs.home-manager.enable = true;
  programs.uv.enable = true;
  services.locate.enable = lib.mkIf pkgs.stdenv.isLinux true;
}
