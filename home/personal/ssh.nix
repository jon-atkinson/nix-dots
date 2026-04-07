{ config, ... }:

{
  sops.defaultSopsFile = ../../secrets/personal/misc.yaml;
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  sops.secrets."id_ed25519" = {
    path = "${config.home.homeDirectory}/.ssh/id_ed25519";
    mode = "0600";
  };
  sops.secrets."glassgate" = {
    path = "${config.home.homeDirectory}/.ssh/glassgate";
    mode = "0600";
  };
  sops.secrets."cluster-gateway-droplet" = {
    path = "${config.home.homeDirectory}/.ssh/cluster-gateway-droplet";
    mode = "0600";
  };
  sops.secrets."config" = {
    path = "${config.home.homeDirectory}/.ssh/config";
    mode = "0600";
  };

  home.file.".ssh/id_ed25519.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKv811OSTjmJXhAEXRI7irLNysvPNAa0XCKwD9mi73WN 95665780+jon-atkinson@users.noreply.github.com";
  home.file.".ssh/glassgate.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJrrXql3UrLCSc89GYWMNn3ippMKFpn6y564bbzbXBO1 Jon@JAM-244.local";
  home.file.".ssh/cluster-gateway-droplet.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJnHWFBgYa3ijB+VBVWwpN6lkxa5QTMnAZcKlc99WnSA Jon@JAM-244.local";
}
