{ pkgs, ... }:

{
  home.packages = with pkgs; [
    plocate
  ];
  services.plocate = {
    enable = true;
    updateInterval = "daily";
  };
}
