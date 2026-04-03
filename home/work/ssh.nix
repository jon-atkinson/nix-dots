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

  home.file.".ssh/officepc.pub".text =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILMAt8S9WUOBTQQ6sMPEbdBzgKyjErO/IIGxCLgurBJH jonathan.atkinson@vivcourt.com";
  home.file.".ssh/authorized_keys" = {
    text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKv811OSTjmJXhAEXRI7irLNysvPNAa0XCKwD9mi73WN 95665780+jon-atkinson@users.noreply.github.com";
    onChange = "chmod 600 ~/.ssh/authorized_keys";
  };
}
