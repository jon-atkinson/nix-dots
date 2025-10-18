{ pkgs, ... }:

{
  home.packages = with pkgs; [
    plocate
  ];
  home.services.plocate = {
    enable = true;
    updateInterval = "daily";
  };
}
