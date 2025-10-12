{ config, ... }:
let
  palette = config.colorScheme.palette;

  colorPrimary = "#${palette.base0C}";
  colorBackground = "#${palette.base00}";
  colorHoverText = "#${palette.base05}";
in
{
  programs.wlogout = {
    enable = true;

    layout = [
      {
        label = "lock";
        action = "hyprlock";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "hibernate";
        action = "systemctl hibernate";
        text = "Hibernate";
        keybind = "h";
      }
      {
        label = "logout";
        action = "hyprctl dispatch exit";
        text = "Logout";
        keybind = "e";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "Suspend";
        keybind = "u";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
    ];

    style = ''
      @define-color primary ${colorPrimary};
      @define-color background ${colorBackground};
      @define-color background-t alpha(@background, 0.8);

      * {
        font-family: "JetBrainsMono Nerd Font", "Symbols Nerd Font Mono";
        font-size: 16px;
        font-weight: bold;
        color: @primary;
        background: @background-t;
      }

      window {
        background: transparent;
      }

      button {
        background: @background-t;
        border: 1px solid @primary;
        border-radius: 10px;
        padding: 20px;
        margin: 10px;
        transition: all 0.2s ease;
      }

      button:hover {
        background: alpha(@primary, 0.1);
        border-color: @primary;
        color: ${colorHoverText};
      }
    '';
  };
}
