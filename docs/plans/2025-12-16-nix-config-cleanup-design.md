# Nix Config Cleanup Plan

## Overview

Cleanup and consolidation of nix-darwin + home-manager configuration to remove unused code, eliminate duplication, and consolidate the Dracula color theme.

## Changes to darwin-configuration.nix

### Remove Outdated Comments
- Lines 1-2: "Home manager and Flakes support will be added later" (already implemented)
- Line 99: "MIGRATED TO HOME MANAGER" with "NOT WORKING" note (resolved)

### Remove Commented Code
- Line 52: `#environment.variables.EDITOR = "nvim";`
- Line 55: `#neovim-unwrapped`
- Lines 82-84: Commented custom config path explanation
- Lines 86-87: Commented `nix.package` lines

### Remove Duplicate Setting
- Line 106: `programs.zsh.enableSyntaxHighlighting = true;` (duplicates home-manager's `syntaxHighlighting.enable = true`)

## Changes to home.nix

### Remove Unused Code
- Lines 59-70: Empty `plugins = [ ];` array with commented block inside
- Lines 171-173: Commented MesloLGS font alternative
- Lines 271-280: `mytestfile` placeholder with dummy values

### Remove Duplicate Plugin
- Line 84 in zplug plugins: `{ name = "plugins/zsh-syntax-highlighting"; tags = [from:oh-my-zsh]; }` (syntax highlighting already enabled via `syntaxHighlighting.enable = true`)

### Fix PATH Export
- Line 53: Remove trailing `:` and `$NIX_PATH` from PATH (NIX_PATH is for channel lookups, not executables)

Before:
```nix
export PATH=/opt/homebrew/bin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:/run/current-system/sw/bin:/Users/dorukakinci/.local/bin:$PATH:$NIX_PATH:
```

After:
```nix
export PATH=/opt/homebrew/bin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:/run/current-system/sw/bin:/Users/dorukakinci/.local/bin:$PATH
```

### Consolidate Dracula Colors

Add a `let` binding at the start of the home-manager user config:

```nix
home-manager.users.dorukakinci = { pkgs, lib, config, ... }:
let
  dracula = {
    bg = "#282a36";
    fg = "#f8f8f2";
    selection = "#44475a";
    comment = "#6272a4";
    cyan = "#8be9fd";
    green = "#50fa7b";
    orange = "#ffb86c";
    pink = "#ff79c6";
    purple = "#bd93f9";
    red = "#ff5555";
    yellow = "#f1fa8c";
    # Bright variants for alacritty
    bright = {
      black = "#6272a4";
      red = "#ff6e6e";
      green = "#69ff94";
      yellow = "#ffffa5";
      blue = "#d6acff";
      magenta = "#ff92df";
      cyan = "#a4ffff";
      white = "#ffffff";
    };
  };
in {
```

Update fzf colors to use `dracula.*` references.

Update alacritty colors to use `dracula.*` references.

Ghostty remains unchanged (uses built-in `theme = "Dracula+"`).

## Verification

After changes, run:
```bash
darwin-rebuild build --flake ~/.nixpkgs/.#
```

If successful, apply with:
```bash
sudo darwin-rebuild switch --flake ~/.nixpkgs/.#
```
