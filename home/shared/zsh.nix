{
  mode,
  lib,
  ...
}:

{
  home.shell.enableZshIntegration = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "minimal";
      plugins = [
        "git"
        "fzf"
      ];
    };
    initContent = lib.mkMerge [
      ''
        # Fuzzy find a file to open with NeoVim. Also add the `nvim <filename>` to history
        nv() {
            local _NF
            _NF=$(fzf) || return
            print -s "nvim $_NF"
            nvim "$_NF"
            unset _NF
            # fx -W
        }

        alias vn=nv

        HISTORY_IGNORE="nv:ls:ll"
      ''    
      (lib.mkIf (mode == "work") ''
        # dwt setup
        source $HOME/repo/dwt/dwt-completion.bash

        # KDB env
        local _PS1="$PS1"
        _source_bashrc() {
          emulate -L bash
          . $NECTAR_DIR/var/common/etc/bashrc
        }
        _source_bashrc
        PS1="$_PS1"
        unset -f _source_bashrc
        emulate bash -c "source $NECTAR_DIR/var/common/kdb/env.sh"

        # Conda environments
        alias env-olympus="source $HOME/miniconda/bin/activate olympus"
        alias env-pt="source $HOME/miniconda/bin/activate pt"
        alias envbase="source ~/miniconda/bin/activate"
      
        # Mosek settings
        MOSEKPLATFORM=linux64x86
        export PATH=$PATH:$NECTAR_DIR/opt/mosek/6/tools/platform/$MOSEKPLATFORM/bin
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NECTAR_DIR/opt/mosek/6/tools/platform/$MOSEKPLATFORM/bin
        export MOSEKLM_LICENSE_FILE=$NECTAR_DIR/opt/mosek/6/licenses
        export MOSEK_USE_NUMPY=1
        
        # q settings
        export DISABLE_TASKSET_FOR_Q=1
        export QINIT=$NECTAR_DIR/var/common/kdb/q.q

        alias clear=/usr/bin/clear

        # feature: create a dwt container and open a zellij workspace
        feature() {
          local name="''${1:?Usage: feature <name>}"
          local layout_template="$HOME/.config/zellij/layouts/feature.kdl"
          local layout
          layout=$(mktemp /tmp/feature-layout-XXXXX.kdl)

          if [[ ! -f "$layout_template" ]]; then
            echo "error: layout template not found at $layout_template"
            return 1
          fi

          # Ensure the olympus conda env is active so dwt is on PATH
          source $HOME/miniconda/bin/activate olympus

          DWT_NAME="$name" envsubst '$DWT_NAME' < "$layout_template" > "$layout"

          local dwt_status=""
          if dwt ls 2>/dev/null | grep -q "^$name .*running"; then dwt_status="running"
          elif dwt ls 2>/dev/null | grep -q "^$name .*stopped"; then dwt_status="stopped"
          fi

          if [[ "$dwt_status" == "running" ]]; then
            echo "Container '$name' is already running, skipping creation."
          elif [[ "$dwt_status" == "stopped" ]]; then
            echo "Starting stopped container '$name'..."
            dwt attach "$name" &
            sleep 3
            zellij action write-chars "exit"
            zellij action write 13
            wait
          else
            echo "Creating dwt environment '$name'..."

            # Background watcher: auto-detach from the tmux session once the
            # container is fully set up (tmux session attached, meaning dwt
            # create has finished cloning and container setup).
            (
              while ! dwt ls 2>/dev/null | grep -q "^$name .*running"; do
                sleep 1
              done
              local container
              container=$(dwt ls 2>/dev/null | grep "^$name " | tr -s ' ' | cut -d' ' -f2)
              while ! podman exec "$container" tmux list-sessions 2>/dev/null | grep -q "attached"; do
                sleep 1
              done
              sleep 1
              zellij action write-chars "exit"
              zellij action write 13
            ) &
            local watcher_pid=$!

            dwt create "$name"
            local create_exit=$?

            kill $watcher_pid 2>/dev/null
            wait $watcher_pid 2>/dev/null

            if [[ $create_exit -ne 0 ]] || ! dwt ls 2>/dev/null | grep -q "^$name .*running"; then
              echo "error: dwt create failed for '$name'"
              rm -f "$layout"
              return 1
            fi
          fi

          echo "Opening zellij workspace..."

          zellij action new-tab --layout "$layout" --name "$name"

          sleep 3

          # Bottom-right pane (claude): start claude code
          zellij action move-focus right
          zellij action move-focus down
          zellij action write-chars "claude --name $name --permission-mode auto --model opus"
          zellij action write 13

          # Automate claude onboarding if this is a fresh container:
          # 1. Select "5. Dark Mode (ANSI colors only)"
          # 2. Select "1. Claude account with subscription"
          sleep 5
          zellij action write-chars "5"
          zellij action write-chars "1"

          # Focus stays on the bottom-right claude pane

          rm -f "$layout"
        }
      '')
    ];
    envExtra = lib.mkIf (mode == "work") ''
      source $HOME/zbx
      source $HOME/kdb
      export PATH=$HOME/.dotnet:$PATH
      export VIVSPACK_ROOT=$HOME/repo/vivspack
      export NECTAR_DIR=$HOME/repo/nectar
      export KDB_DIR=~/olympus/data/kdb
      export RESEARCH_DIR=~/olympus/data/research
      export KDB_PROD_HOST=sy2-oly-app1
      export KDB_PROD_DIR=/prod/kdb
      export KDB_DATA_HOST=sy2-oly-app2
      export KDB_DATA_DIR=/data/kdb
      export KDB_DATA_USER=olympusdata
    '';
  };
}
