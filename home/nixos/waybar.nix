{ config, pkgs, ... }:

let
  palette = config.colorScheme.palette;

  # prepends a hash character to base16 codes
  hash = s: "#${s}";

  colorPrimary = hash palette.base0C;
  colorBackground = hash palette.base00;
  colorInactive = hash palette.base02;
  colorUrgentBg = hash palette.base0B;
  colorUrgentText = hash palette.base00;
  colorHover = hash palette.base03;
  colorHoverText = hash palette.base05;
  colorTooltipBorder = hash palette.base01;
  colorBattery = hash palette.base0B;
  colorTemperatureCritical = hash palette.base08;
  colorPowerBalanced = hash palette.base09;
  colorPowerPowerSaver = hash palette.base0E;

in
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [
          "hyprland/workspaces"
          "tray"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "cpu"
          "temperature"
          "memory"
          "battery"
          "network"
          "bluetooth"
          "custom/notification"
          "custom/power"
        ];
        clock = {
          format = "{:%d %H:%M}";
          tooltip = false;
        };
        cpu = {
          format = " {usage}%";
          tooltip = false;
        };
        temperature = {
          format = " {temperatureC}°C";
          tooltip = false;
        };
        memory = {
          format = " {percentage}%";
          tooltip = false;
        };
        battery = {
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-alt = "{time}";
          tooltip = true;
          states = {
            warning = 30;
            critical = 15;
          };
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };
        network = {
          format-wifi = "  {essid} ({signalStrength}%)";
          format-ethernet = "󰈀 {ifname}";
          format-disconnected = " Disconnected";
          on-click = "networkmanager_dmenu";
        };
        bluetooth = {
          # "controller": "controller1", # specify the alias of the controller if there are more than 1 on the system
          format = " {status}";
          format-disabled = ""; # an empty format will hide the module
          format-connected = " {num_connections} connected";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          on-click = "rofi-bluetooth";
        };
        "custom/notification" = {
          exec = "${pkgs.writeShellScript "mako-mode-indicator" ''
            	    if makoctl mode | grep -q "^focus$"; then
            	      echo '{"text": "🔕", "tooltip": "Focus Mode"}'
            	    else
            	      echo '{"text": "🔔", "tooltip": "Normal Mode"}'
            	    fi
            	  ''}";
          return-type = "json";
          interval = 2;
          on-click = "makoctl mode -t focus";
          tooltip = true;
        };
        "custom/power" = {
          format = "";
          tooltip = false;
          on-click = "wlogout";
        };
      };
    };

    style = ''
      @define-color primary ${colorPrimary};
      @define-color background ${colorBackground};
      @define-color background-t alpha(${colorBackground}, 0.8);

      /* All Modules */
      * {
        font-family: "JetBrainsMono Nerd Font", "Symbols Nerd Font Mono";
        font-weight: bold;
        font-size: 13px;
        padding: 0;
        background: alpha(${colorBackground}, 0);
      }
      window#waybar {
        background: transparent;
        border: none;
        color: @primary;
      }
      tooltip {
        background: @background;
        border-radius: 10px;
        border-width: 10px;
        border-style: solid;
        border-color: ${colorTooltipBorder};
      }
      menu menuitem:hover {
        background-color: alpha(${colorPrimary}, 0.1);
        border-color: @primary;
      }

      /* Workspaces */
      #workspaces button {
        color: ${colorInactive};
      }
      #workspaces button.active {
        color: @primary;
      }
      #workspaces button.urgent {
        color: ${colorUrgentText};
        background: ${colorUrgentBg};
        border-radius: 10px;
      }
      #workspaces button:hover {
        background: ${colorHover};
        color: ${colorHoverText};
        border-color: @primary;
        border-radius: 10px;
      }

      /* Bar modules */
      #window,
      #workspaces,
      #custom-clipboard,
      #menu,
      #submap,
      #idle_inhibitor,
      #pulseaudio,
      #battery,
      #bluetooth,
      #network,
      #power-profiles-daemon,
      #cpu,
      #memory,
      #temperature,
      #keyboard-state,
      #clock,
      #tray,
      #custom-brightness,
      #custom-updates,
      #custom-notification,
      #custom-power,
      #custom-weather,
      #custom-menu,
      #custom-razerbattery,
      #wlr-taskbar {
        background: @background;
        font-family: "JetBrainsMono Nerd Font", "Symbols Nerd Font Mono", "NotoSansMono Nerd Font";
        opacity: 1.0;
        padding: 0px 10px;
        margin: 0px 2px;
        margin-top: 5px;
        border: 0.5px solid @primary;
        border-radius: 10px;
      }

      /* Individual modules */
      #submap {
        background-color: alpha(${colorBackground}, 0.8);
        color: ${colorBattery};
      }
      menu {
        background-color: @background;
        border: 1px solid @primary;
        border-radius: 10px;
      }
      #battery {
        color: ${colorBattery};
        padding-right: 15px;
      }
      #power-profiles-daemon.performance { 
        color: @primary; 
      }
      #power-profiles-daemon.balanced { 
        color: ${colorPowerBalanced}; 
      }
      #power-profiles-daemon.power-saver { 
        color: ${colorPowerPowerSaver}; 
      }
      #temperature.critical {
        color: ${colorTemperatureCritical}; 
      }
      #clock {
        margin-right: 5px;
      }
      #custom-clipboard {
        padding-left: 11px;
        padding-right: 12px;
      }
      #custom-updates {
        padding-right: 15px;
      }
      /*#custom-notification {
        font-family: "NotoSansMono Nerd Font";
        font-size: 16px;
        padding-right: 15px;
      }*/
      #custom-power {
        margin-left: 5px;
        padding-left: 5px;
      }
      #custom-razerbattery {
        padding-right: 0px;
      }

      /* Not Used CSS Modules, defined with other Modules above */
      #tray {
      /* Add unique CSS Options */
      }
      #workspaces {
      /* Add unique CSS Options */
      }
      #workspaces button.focused {
      /* Add unique CSS Options */
      }
      #custom-weather {
      /* Add unique CSS Options */
      }
      #custom-menu {
      /* Add unique CSS Options */
      }
      #keyboard-state {
      /* Add unique CSS Options */
      }
      #temperature { 
      /* Add unique CSS Options */
      }
      #power-profiles-daemon {
      /* Add unique CSS Options */
      }
      #pulseaudio,
      #pulseaudio.microphone {
      /* Add unique CSS Options */
      }
      #custom-brightness {
      /* Add unique CSS Options */
      }
      #network {
      /* Add unique CSS Options */
      }
      #bluetooth {
      /* Add unique CSS Options */
      }
      #cpu {
      /* Add unique CSS Options */
      }
      #memory {
      /* Add unique CSS Options */
      }
      #idle_inhibitor {
      /* Add unique CSS Options */
      }
    '';

  };
}
