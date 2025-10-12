{
  ...
}:

{
  programs.zellij = {
    enable = true;
    attachExistingSession = true;
    enableZshIntegration = true;
    settings = {
      show_startup_tips = false;
      theme = "lucario";
    };
  };
}
