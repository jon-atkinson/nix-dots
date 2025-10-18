{
  pkgs,
  lib,
  ...
}:

{
  services.locate.enable = lib.mkIf pkgs.stdenv.isLinux true;

  users.users.jon = {
    isNormalUser = true;
    description = "Jon Atkinson";
    # openssh.authorizedKeys.keys = [];
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "audio"
      "input"
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    nix-prefetch-git
    git
    vim
    wget
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "25.05";
}
