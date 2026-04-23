{ pkgs, ... }:

{
  home.packages = [ pkgs.envsubst ];

  home.file.".config/zellij/layouts/feature.kdl".text = ''
    layout {
      default_tab_template {
        pane size=1 borderless=true {
          plugin location="tab-bar"
        }
        children
        pane size=2 borderless=true {
          plugin location="status-bar"
        }
      }
      tab name="$DWT_NAME" focus=true {
        pane split_direction="vertical" {
          pane size="50%" cwd="/home/jon/worktrees/$DWT_NAME" command="zsh" {
            args "-i" "-c" "nv; exec zsh -i"
            focus true
          }
          pane size="50%" split_direction="horizontal" {
            pane size="50%" command="bash" {
              args "-c" "source $HOME/miniconda/bin/activate olympus && dwt shell $DWT_NAME"
            }
            pane size="50%" command="bash" {
              args "-c" "source $HOME/miniconda/bin/activate olympus && dwt shell $DWT_NAME"
            }
          }
        }
      }
    }
  '';
}
