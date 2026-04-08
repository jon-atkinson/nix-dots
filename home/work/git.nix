{ config, ... }:

{
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  sops.secrets."git_name" = {
    sopsFile = ../../secrets/work/misc.yaml;
  };
  sops.secrets."git_email" = {
    sopsFile = ../../secrets/work/misc.yaml;
  };

  sops.templates."git-config" = {
    content = ''
      [user]
      	name = ${config.sops.placeholder."git_name"}
      	email = ${config.sops.placeholder."git_email"}
      [core]
      	editor = nvim
    '';
    path = "${config.home.homeDirectory}/.config/git/config";
  };
}
