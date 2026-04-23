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

          # Automate claude onboarding by polling the pane screen for expected
          # prompts. Skips cleanly if these screens don't appear (e.g. claude
          # is already authed).
          local screen
          screen=$(mktemp)
          _feature_wait_for() {
            local pattern="$1"
            local max_iter="''${2:-60}"
            local i=0
            while (( i < max_iter )); do
              zellij action dump-screen "$screen" 2>/dev/null
              if grep -qi "$pattern" "$screen"; then
                echo "[feature] matched '$pattern' after $((i * 200))ms" >&2
                return 0
              fi
              sleep 0.2
              ((i++))
            done
            echo "[feature] timed out waiting for '$pattern' after $((max_iter * 200))ms" >&2
            echo "[feature] last screen dump:" >&2
            cat "$screen" >&2
            return 1
          }

          if _feature_wait_for "Dark Mode"; then
            zellij action write-chars "5"
            if _feature_wait_for "subscription"; then
              zellij action write-chars "1"
              # Wait for the auth URL to appear, then extract and open on host.
              # The URL wraps across multiple terminal lines, so reconstruct it
              # by concatenating continuation lines. Pick the longest URL on
              # screen since claude shows a short display URL + the full URL.
              if _feature_wait_for "https://"; then
                zellij action write-chars "c"
                sleep 0.3
                zellij action dump-screen "$screen" 2>/dev/null
                local auth_url
                auth_url=$(awk '
                  function save_if_longer() {
                    if (length(cur) > length(longest)) longest = cur
                    cur = ""; in_url = 0
                  }
                  BEGIN { in_url = 0; longest = ""; cur = "" }
                  {
                    if (in_url) {
                      if ($0 ~ /^[^[:space:]]+$/) { cur = cur $0; next }
                      save_if_longer()
                    }
                    if ($0 ~ /https:\/\//) {
                      match($0, /https:\/\/[^[:space:]]*/)
                      cur = substr($0, RSTART)
                      in_url = 1
                    }
                  }
                  END { save_if_longer(); print longest }
                ' "$screen")
                if [[ -n "$auth_url" ]]; then
                  xdg-open "$auth_url" >/dev/null 2>&1 &!
                  echo "[feature] opened auth URL in browser: $auth_url" >&2
                else
                  echo "[feature] failed to extract auth URL from screen" >&2
                fi
                # Wait up to 5 minutes for the user to complete browser auth
                if _feature_wait_for "Login successful" 1500; then
                  zellij action write 13
                  if _feature_wait_for "Security notes"; then
                    zellij action write 13
                    if _feature_wait_for "trust this folder"; then
                      zellij action write 13
                      if _feature_wait_for "Enable auto mode"; then
                        zellij action write 13
                      fi
                    fi
                  fi
                fi
              fi
            fi
          fi
          rm -f "$screen"
          unset -f _feature_wait_for

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
