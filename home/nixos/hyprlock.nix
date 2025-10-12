{ config, ... }:

let
  palette = config.colorScheme.palette;

  colorPrimary = "0xFF${palette.base0C}";
  colorBackground = "0xF0${palette.base00}";
  wallpaperPath = "/home/jon/.local/share/wallpapers/background.png";
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = {
        path = wallpaperPath;
        blur_passes = 3;
        blur_size = 8;
      };

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = true;
          font_color = colorPrimary;
          inner_color = colorBackground;
          outer_color = colorPrimary;
          outline_thickness = 1;
          placeholder_text = "password...";
          shadow_passes = 0;
        }
      ];
    };
  };
}
