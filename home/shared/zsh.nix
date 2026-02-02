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
    '';
  };
}
