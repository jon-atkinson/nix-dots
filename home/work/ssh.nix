{ config, ... }:

{
  sops.defaultSopsFile = ../../secrets/work/ssh.yaml;
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  sops.secrets."officepc" = {
    path = "${config.home.homeDirectory}/.ssh/officepc";
    mode = "0600";
  };
  sops.secrets."config" = {
    path = "${config.home.homeDirectory}/.ssh/config";
    mode = "0600";
  };

  # TODO: replace with actual content from work machine
  home.file.".ssh/officepc.pub".text = "REPLACEME";
  home.file.".ssh/authorized_keys" = {
    text = "REPLACEME";
    onChange = "chmod 600 ~/.ssh/authorized_keys";
  };
}
