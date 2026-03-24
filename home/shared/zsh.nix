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
        source $HOME/dwt/dwt-completion.bash

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
      '')
    ];
    envExtra = lib.mkIf (mode == "work") ''
      source $HOME/zabbix_creds.sh
      source $HOME/kdb_creds
      export PATH=$HOME/.dotnet:$PATH
      export DOTNET_ROOT=$HOME/.dotnet
      export VIVSPACK_ROOT=$\{HOME}/vivspack
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
