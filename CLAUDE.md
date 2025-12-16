# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a nix-darwin + home-manager flake configuration for macOS (Apple Silicon). It manages system configuration, user environment, dotfiles, and Homebrew casks declaratively.

## Key Commands

```bash
# Apply configuration changes (requires sudo for system activation)
nix-switch                    # alias defined in shell config

# Manual equivalent
sudo darwin-rebuild switch --flake ~/.nixpkgs/.#

# Update flake inputs
nix flake update

# Check configuration without applying
darwin-rebuild build --flake ~/.nixpkgs/.#
```

## Architecture

### File Structure

- **flake.nix** - Flake entry point defining inputs (nixpkgs 25.11, nix-darwin 25.11, home-manager 25.11) and the darwin configuration for hostname `TRENGDOAKMAC`
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
