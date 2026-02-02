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
    initContent = ''
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

      # setup q config
      export QHOME=~/q
      export PATH=~/q/m64/:$PATH
      alias q="rlwrap -r q"
    '';
    envExtra = lib.mkIf (mode == "work") ''
    # DEPLOYMENT setup
    export VIVSPACK_ROOT=${HOME}/vivspack

    # NECTAR setup
    # Define local directories
    export NECTAR_DIR=$HOME/nectar
    export KDB_DIR=/data/kdb
    export RESEARCH_DIR=/data/research
    
    # Remote data sources
    export KDB_PROD_HOST=sy2-oly-app1
    export KDB_PROD_DIR=/prod/kdb
    export KDB_DATA_HOST=sy2-oly-app2
    export KDB_DATA_DIR=/data/kdb
    export KDB_DATA_USER=olympusdata
    
    # # KDB credentials
    # export KDB_USER=username
    # export KDB_PW=password
    
    # KDB env
    source $NECTAR_DIR/var/common/etc/bashrc
    source $NECTAR_DIR/var/common/kdb/env.sh
    
    # Conda environments
    alias env-olympus='source $HOME/miniconda/bin/activate olympus'
    alias env-pt='source $HOME/miniconda/bin/activate pt'
    
    # Mosek settings
    MOSEKPLATFORM=linux64x86
    export PATH=$PATH:$NECTAR_DIR/opt/mosek/6/tools/platform/$MOSEKPLATFORM/bin
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NECTAR_DIR/opt/mosek/6/tools/platform/$MOSEKPLATFORM/bin
    export MOSEKLM_LICENSE_FILE=$NECTAR_DIR/opt/mosek/6/licenses
    export MOSEK_USE_NUMPY=1
    
    # q settings
    export DISABLE_TASKSET_FOR_Q=1
    export QINIT=$NECTAR_DIR/var/common/kdb/q.q
    '';
  };
}
