{
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
    initExtra = ''
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
  };
}
