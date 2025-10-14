# nix-dots

Personal dev env system config. By no means the most elegant way of doing this.

Heuristics: correct, stable, simple, modular

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

1. Select the correct branch for your use case.

2. [Install nix](https://nixos.org/download/), preferrably multi-user if permissable.

3. Run the relevant install command for your use case.

| NixOS Desktop                                                                                                                                                                                             | NixOS Headless                                                                                                                                                                                             | Darwin Home Manager                                                                                                                                                                                          | x86-64_linux Home Manager                                                                                                                                                                                                    |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <pre>sudo nixos-rebuild switch \\<br>--flake "github:jon-atkinson/nix-dots/tree/telemetry-free#nixos-wm" \\<br>--extra-experimental-features nix-command \\<br>--extra-experimental-features flakes</pre> | <pre>sudo nixos-rebuild switch \\<br>--flake "github:jon-atkinson/nix-dots/tree/telemetry-free#nixos-wsl" \\<br>--extra-experimental-features nix-command \\<br>--extra-experimental-features flakes</pre> | <pre>nix run "github:jon-atkinson/nix-dots/tree/telemetry-free#homeConfigurations.darwin.activationPackage" \\<br>--extra-experimental-features nix-command \\<br>--extra-experimental-features flakes</pre> | <pre>nix run "github:jon-atkinson/nix-dots/tree/telemetry-free#homeConfigurations.linux-generic-headless.activationPackage" \\<br>--extra-experimental-features nix-command \\<br>--extra-experimental-features flakes</pre> |

4. Finally, update the default shell to zsh.

```
sudo chsh -s $(which zsh) $USER
```
