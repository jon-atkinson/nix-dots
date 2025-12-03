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
      # Add MHS development tools to PATH
      export MORSE_ARM_PATH=/opt/morse/gcc-arm-none-eabi-10.3-2021.07/bin
      export MORSE_OPENOCD_PATH=/opt/morse/xpack-openocd-0.12.0-2/bin
      export PATH=$MORSE_ARM_PATH:$MORSE_OPENOCD_PATH:$PATH
      PATH=$HOME/.local/bin:$PATH

      # Add Firmware development tools to environment
      source /opt/modules/init/profile.sh
      module switch riscv-gcc/20220921
      module switch riscv-openocd/20230322
      module switch gdb/14.2
      module switch uncrustify/0.72.0
    '';
  };
}
