{ pkgs, ... }:

{
  home.packages = [ pkgs.envsubst ];

  home.file.".config/zellij/layouts/feature.kdl".text = ''
    layout {
      tab name="$DWT_NAME" focus=true {
        pane split_direction="vertical" {
          pane size="50%" command="dwt" {
            args "shell" "$DWT_NAME"
            focus true
          }
          pane size="50%" split_direction="horizontal" {
            pane size="50%" command="dwt" {
              args "shell" "$DWT_NAME"
            }
            pane size="50%" command="dwt" {
              args "shell" "$DWT_NAME"
            }
          }
        }
      }
    }
  '';
}
