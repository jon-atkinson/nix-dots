{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    rofi
  ];

  programs.rofi = {
    enable = true;
  };

  xdg.configFile."rofi/config.rasi".text =
    let
      inherit (config.colorScheme) palette;
      hash = s: "#${s}";
    in
    ''
      /* configuration {
        modes: "window,drun,run,bluetooth:rofi-bluetooth,combi";
        combi-modes: "drun,bluetooth";
        display-bluetooth: " Bluetooth";
        display-drun: "Apps";
      } */

      * {
          font: "JetBrainsMono Nerd Font 13";
          show-icons: true;

          /* Color mapping aligned with Waybar */
          bg0: ${hash palette.base00}; /* background */
          bg1: ${hash palette.base01}; /* slightly lighter background for input */
          bg2: ${hash palette.base02}; /* inactive/secondary */
          bg3: ${hash palette.base0C}; /* primary / outline / accent */

          fg0: ${hash palette.base05}; /* main text */
          fg1: ${hash palette.base05};
          fg2: ${hash palette.base05};
          fg3: ${hash palette.base03}; /* hover text */

          background-color: transparent;
          text-color: @fg0;

          margin: 0px;
          padding: 0px;
          spacing: 0px;
      }

      window {
          location: north;
          y-offset: calc(50% - 176px);
          width: 480;
          border-radius: 24px;

          background-color: @bg0;
          border: 2px;
          vorder-color: @bg3;
      }

      mainbox {
          padding: 12px;
      }

      inputbar {
          background-color: @bg1;
          border-color: @bg3;

          border: 2px;
          border-radius: 16px;

          padding: 8px 16px;
          spacing: 8px;
          children: [ prompt, entry ];
      }

      prompt {
          text-color: @fg2;
      }

      entry {
          placeholder: "Search";
          placeholder-color: @fg3;
      }

      message {
          margin: 12px 0 0;
          border-radius: 16px;
          border-color: @bg2;
          background-color: @bg2;
      }

      textbox {
          padding: 8px 24px;
      }

      listview {
          background-color: transparent;

          margin: 12px 0 0;
          lines: 8;
          columns: 1;

          fixed-height: true;
          height: 200px;
      }

      element {
          padding: 8px 16px;
          spacing: 8px;
          border-radius: 16px;
          children: [ element-icon, element-text ];
      }

      element normal active,
      element alternate active {
          text-color: @bg3;
      }

      element selected normal,
      element selected active {
          background-color: @bg3;
          text-color: @bg1;
      }

      element-icon {
          size: 1em;
          vertical-align: 0.5;
      }

      element-text {
          text-color: inherit;
      }
    '';
}
