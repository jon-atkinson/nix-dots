{
  pkgs,
  ...
}:
let
  sddm-astronaut = pkgs.sddm-astronaut.override {
    # options: astronaut, black_hole, cyberpunk, hyprland_kath, jake_the_dog, japanese_aesthetic, pixel_sakura, pixel_sakura_static, post-apocalyptic_hacker, purple_leaves
    embeddedTheme = "pixel_sakura";
  };
in
{
  environment.systemPackages = [
    sddm-astronaut
  ];

  services = {
    xserver.enable = true;

    displayManager = {
      sddm = {
        wayland.enable = true;
        enable = true;
        package = pkgs.kdePackages.sddm;

        theme = "sddm-astronaut-theme";

        extraPackages = [ sddm-astronaut ];
      };
      autoLogin = {
        enable = false;
        user = "jon";
      };
    };
  };
}
