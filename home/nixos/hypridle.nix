{ pkgs, ... }:

{

  home.packages = with pkgs; [
    hypridle
    brightnessctl
  ];

  home.sessionVariables.HYPRIDLE_LOCK_COMMAND = "hyprlock";

  xdg.configFile."hypr/hypridle.conf".text = ''
    general {
        lock_cmd = pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd = ${pkgs.hyprland}/bin/hyprctl dispatch dpms on
    }

    listener {
        timeout = 150
        on-timeout = ${pkgs.brightnessctl}/bin/brightnessctl -s set 10
        on-resume = ${pkgs.brightnessctl}/bin/brightnessctl -r
    }

    listener { 
        timeout = 150
        on-timeout = ${pkgs.brightnessctl}/bin/brightnessctl -sd rgb:kbd_backlight set 0
        on-resume = ${pkgs.brightnessctl}/bin/brightnessctl -rd rgb:kbd_backlight
    }

    listener {
        timeout = 300
        on-timeout = ${pkgs.hyprlock}/bin/hyprlock
    }

    listener {
        timeout = 330
        on-timeout = ${pkgs.hyprland}/bin/hyprctl dispatch dpms off
        on-resume = ${pkgs.hyprland}/bin/hyprctl dispatch dpms on && ${pkgs.brightnessctl}/bin/brightnessctl -r
    }

    listener {
        timeout = 1800
        on-timeout = systemctl suspend
    }
  '';
}
