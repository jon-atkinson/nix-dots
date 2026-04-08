{ config, ... }:

{
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  sops.secrets."git_name" = {
    sopsFile = ../../secrets/personal/misc.yaml;
  };
  sops.secrets."git_email" = {
    sopsFile = ../../secrets/personal/misc.yaml;
  };

  sops.templates."git-user-config" = {
    content = ''
      [user]
      	name = ${config.sops.placeholder."git_name"}
      	email = ${config.sops.placeholder."git_email"}
    '';
  };

  programs.git.includes = [
    { path = config.sops.templates."git-user-config".path; }
  ];
}
