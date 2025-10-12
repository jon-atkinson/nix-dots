{
  inputs,
  config,
  pkgs,
  ...
}:

{
  colorScheme = inputs.nix-colors.colorSchemes.kanagawa;

  imports = [
    ./hypridle.nix
    ./hyprlock.nix
    ./networking.nix
    ./rofi.nix
    ./waybar.nix
    ./wlogout.nix
  ];

  # packages used by more than one application may be declared elsewhere as well
  home.packages = with pkgs; [
    brightnessctl
    caprine
    rofi-bluetooth
    teams-for-linux
  ];

  # terminal
  programs.kitty = {
    enable = true;
    settings = {
      copy_on_select = "yes";
    };

    extraConfig = ''
      mouse_map right click ungrabbed copy_to_clipboard
      mouse_map right press ungrabbed paste_to_clipboard
    '';
  };

  # bluetooth
  services.mpris-proxy.enable = true;

  # wallpaper
  services.hyprpaper = {
    enable = true;

    settings = {
      ipc = "on";
      splash = false;
      splash_offset = 2.0;

      preload = [ "~/.local/share/wallpapers/background.png" ];

      wallpaper = [
        "eDP-1,~/.local/share/wallpapers/background.png"
        "HDMI-A-1,~/.local/share/wallpapers/background.png"
      ];
    };
  };

  # notifications
  services.mako = {
    enable = true;
    settings = {
      sort = "-time";
      actions = true;
      anchor = "top-right";
      background-color = "#${config.colorScheme.palette.base00}";
      border-color = "#${config.colorScheme.palette.base0C}";
      border-radius = 5;
      default-timeout = 0;
      font = "monospace 10";
      height = 100;
      width = 300;
      icons = true;
      ignore-timeout = false;
      layer = "top";
      margin = 10;
      markup = true;

      "mode=focus" = {
        invisible = 1;
      };

      "urgency=critical mode=focus" = {
        invisible = 0;
        default-timeout = 0;
      };
    };
  };

  programs.obs-studio = {
    enable = true;
  };

  xdg.configFile."hypr/hyprland.conf".text = ''
    monitor = eDP-1, preferred, auto, 2.0
    monitor = HDMI-A-1, preferred, auto-up, 1.0

    # Run on startup
    exec-once = hypridle
    exec-once = waybar
    exec-once = systemctl --user enable --now hyprpaper.service

    # Application Bindings
    bind = SUPER, RETURN, exec, kitty
    bind = SUPER, Q, killactive
    bind = SUPER, C, exec, hyprctl reload
    bind = SUPER, B, exec, chromium
    bind = SUPER + CTRL, Q, exec, wlogout
    bind = SUPER, SPACE, exec, rofi -show drun
    bind = SUPER, J, exec, sudo ydotool key 103:1 103:0
    bind = SUPER, K, exec, sudo ydotool key 108:1 108:0

    # Screenshots
    bind = SUPER, x, exec, hyprshot --mode window --mode active --output-folder ~/screenshots --freeze --silent

    # Notifications
    bind = SUPER, F, exec, makoctl mode -t focus
    bind = SUPER, N, exec, makoctl dismiss
    bind = SUPER, P, exec, makoctl restore

    # Navigation
    bind = SUPER, H, workspace, -1
    bind = SUPER, L, workspace, +1
    bind = SUPER, 1, workspace, 1
    bind = SUPER, 2, workspace, 2
    bind = SUPER, 3, workspace, 3
    bind = SUPER, 4, workspace, 4
    bind = SUPER, 5, workspace, 5

    # Screen Brightness Control
    bind = , XF86MonBrightnessUp, exec, brightnessctl s +10%
    bind = , XF86MonBrightnessDown, exec, brightnessctl s 10%-

    # General Styling
    decoration {
      rounding = 10
    }
  '';
}
