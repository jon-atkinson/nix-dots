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
    rustup

    # formatters
    gofumpt
    nodePackages.prettier
    stylua
    ruff
    nixfmt-rfc-style
  ];

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      l = "ls -al";
    };
  };

  programs.git = {
    enable = true;
    userName = "Jon Atkinson";
    userEmail = "95665780+jon-atkinson@users.noreply.github.com";
  };

  programs.uv.enable = true;

}
