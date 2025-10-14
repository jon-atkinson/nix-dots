nix-dots

Personal system config. By no means the most elegant way of doing this.

Heuristics:

- correct
- stable
- simple
- modular

## Platforms

- NixOS desktop
- NixOS headless (wsl, server)
- darwin home manager (standalone)
- x86-64_linux home manager (standalone)

## Major Tooling

- zsh
- zellij
- nvim

## Setup

[Install nix](https://nixos.org/download/), preferrably multi-user if permissable.

Run the relevant command for your use case.

| NixOS Desktop | NixOS Headless | Darwin Home Manager                                                                                                                                               | x86-64_linux Home Manager                                                                                                                                                         |
| ------------- | -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| TODO: add     | TODO: add      | `nix run github:jon-atkinson/nix-dots#homeConfigurations.darwin.activationPackage --extra-experimental-features nix-command --extra-experimental-features flakes` | `nix run github:jon-atkinson/nix-dots#homeConfigurations.linux-generic-headless.activationPackage --extra-experimental-features nix-command --extra-experimental-features flakes` |

Finally, update the default shell to zsh.

```
sudo chsh -s $(which zsh) $USER
```
