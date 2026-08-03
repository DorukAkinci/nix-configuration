# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a nix-darwin + home-manager flake configuration for macOS (Apple Silicon). It manages system configuration, user environment, dotfiles, and Homebrew casks declaratively.

## Key Commands

```bash
# Apply configuration changes (requires sudo for system activation)
nix-switch                    # alias defined in shell config

# Manual equivalent — the bare `#` resolves the config matching this Mac's hostname
sudo darwin-rebuild switch --flake ~/.nixpkgs/.#

# Explicit host (needed when the hostname does not yet match a list entry)
sudo darwin-rebuild switch --flake ~/.nixpkgs#TRENGDOAKMAC

# Update flake inputs
nix flake update

# Check configuration without applying
darwin-rebuild build --flake ~/.nixpkgs/.#

# List every machine this flake can build
nix eval .#darwinConfigurations --apply builtins.attrNames
```

## Adding a machine

This flake is multi-host. `flake.nix` holds a `hosts` list, and `nixpkgs.lib.genAttrs`
builds one `darwinConfigurations.<hostname>` per entry from the **same** modules
(`darwin-configuration.nix` + `home.nix`). Machines cannot drift apart — there is only
one config; the hostname is the only input that differs.

To onboard a new Mac, add one line:

```nix
hosts = [
  "TRENGDOAKMAC" # MacBook #1
  "NEWHOSTNAME"  # MacBook #2   <-- the whole change
];
```

then on that machine: `sudo darwin-rebuild switch --flake ~/.nixpkgs#NEWHOSTNAME`.

`networking.{hostName,computerName,localHostName}` are set from the list entry, so nix
owns the machine name too — after the first switch the hostname *becomes* the list entry.
Bootstrapping a machine that has no `darwin-rebuild` yet is covered in
`~/mac-bootstrap/AGENT-INSTRUCTIONS.md`.

## Architecture

### File Structure

- **flake.nix** - Flake entry point defining inputs (nixpkgs 25.11, nix-darwin 25.11, home-manager 25.11) and, via the `hosts` list + `mkDarwin`, one darwin configuration per managed machine
- **darwin-configuration.nix** - System-level settings: macOS defaults, system packages, Homebrew casks, zsh system config, Touch ID for sudo
- **home.nix** - User-level settings via home-manager: shell aliases, terminal emulators (alacritty, ghostty), fzf, lsd, powerline-go, dotfile links
- **dotfiles/** - Managed dotfiles (hammerspoon, raycast) linked via home.file

### Configuration Split

| Concern | File | Notes |
|---------|------|-------|
| System packages | darwin-configuration.nix | `environment.systemPackages` |
| GUI apps (casks) | darwin-configuration.nix | `homebrew.casks` |
| macOS defaults | darwin-configuration.nix | `system.defaults` |
| User shell config | home.nix | zsh, aliases, oh-my-zsh, zplug |
| Terminal emulators | home.nix | alacritty, ghostty (Dracula theme) |
| Dotfiles | home.nix | `home.file` with source from ./dotfiles |

### Important Notes

- **Company MDM**: `targets.darwin.copyApps.enable = false` - app copying is disabled due to corporate restrictions
- **fzf integration**: Handled by home-manager only (`enableFzfCompletion/Git/History = false` in darwin) to avoid version conflicts
- **Ghostty**: Installed via Homebrew (`package = null`) since nixpkgs doesn't support darwin
- **Primary user**: Set via `system.primaryUser = "dorukakinci"` (required in nix-darwin 25.11+)

### Tmux + Ghostty Integration

The tmux configuration has several critical settings that must be maintained:

1. **Ghostty command**: Uses `/bin/zsh -l -c 'exec tmux'` to start tmux through a login shell, ensuring PATH is properly set before tmux starts

2. **PATH for plugins**: The `sensible` plugin's `extraConfig` sets `set-environment -g PATH` BEFORE any plugin runs. This is critical because tmux plugin scripts need access to commands in PATH. Placing this in the main `extraConfig` is too late (runs after plugins)

3. **Shell override**: The `sensible` plugin sets `default-command` to use `/bin/sh`. Must override with `set -g default-command "/bin/zsh"` in `extraConfig` to get zsh as the shell

4. **Config file location**: Tmux uses `~/.config/tmux/tmux.conf` (XDG location). Delete any old `~/.tmux.conf` as it takes precedence

5. **Testing changes**: After `nix-switch`, must kill tmux server (`tmux kill-server`) and restart Ghostty for changes to take effect
