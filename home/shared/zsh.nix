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
      nv() {
        local file
        if command -v fd >/dev/null 2>&1; then
            file=$(fd --type f | fzf)
        else
          file=$(find . -type f 2>/dev/null | fzf)
        fi
        if [[ -n "$file" ]]; then
          nvim "$file"
        fi
      }
    '';
    envExtra = lib.mkIf (mode == "work") ''
      # Add development tools to PATH
      export MORSE_ARM_PATH=/opt/morse/gcc-arm-none-eabi-10.3-2021.07/bin
      export MORSE_OPENOCD_PATH=/opt/morse/xpack-openocd-0.12.0-2/bin
      export PATH=$MORSE_ARM_PATH:$MORSE_OPENOCD_PATH:$PATH
      PATH=$HOME/.local/bin:$PATH
    '';
  };
}
