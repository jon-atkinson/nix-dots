{
  pkgs,
  lib,
  config,
  ...
}:

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
    plocate

    # formatters
    gofumpt
    nodePackages.prettier
    stylua
    ruff
    nixfmt-rfc-style
  ];

  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      l = "ls -al";
    };
  };

  programs.uv.enable = true;

  services.cron = {
    enable = true;
    systemCronJobs = lib.mkIf (!config.systemd.enable) [
      # update plocate db @ 4am each morning
      "0 4 * * * ${pkgs.plocate}/bin/updatedb"
    ];
  };
}
