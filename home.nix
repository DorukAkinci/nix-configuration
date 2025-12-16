{ config, lib, pkgs, ... }:
{
    home-manager.useUserPackages = true;
    home-manager.useGlobalPkgs = true;
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
        # Additional colors for alacritty
        currentLine = "#44475a";
        brightWhite = "#ffffff";
        darkBg = "#21222c";
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
        home.stateVersion = "25.11";
        home.username = "dorukakinci";
        home.homeDirectory = "/Users/dorukakinci";

        # Disable app copying (blocked by company MDM)
        targets.darwin.copyApps.enable = false;
        # Show battery percentage in menu bar
        targets.darwin.currentHostDefaults."com.apple.controlcenter".BatteryShowPercentage = true;

        fonts.fontconfig.enable = true;

        home.packages = with pkgs; [
            nerd-fonts.fira-code
            nerd-fonts.meslo-lg
        ];

        programs.nix-index.enable = true;
        programs.nix-index.enableZshIntegration = true;

        programs = {
            zsh = {
                enable = true;
                autocd = true;
                dotDir = "${config.home.homeDirectory}/.config/zsh";
                autosuggestion.enable = true;
                enableCompletion = true;
                syntaxHighlighting.enable = true;

                shellAliases = {
                    git="LANG=en_US git";
                    LANG="en_US.UTF-8";
                    LANG_ALL="en_US.UTF-8";
                    # ls, ll, la, lt, lla, llt are provided by lsd module
                    coffee="caffeinate -u -t 43200";
                    desktop-hide="defaults write com.apple.finder CreateDesktop -bool false && killall Finder";
                    desktop-show="defaults write com.apple.finder CreateDesktop -bool true && killall Finder";

                    repo="cd ~/Git";

                    ssh-add-dorukakinci="ssh-add ~/.ssh/kp_dorukakinci.pem";
                    ssh-add-work="ssh-add ~/.ssh/work.ssh";

                    nix-switch="pushd ~/.nixpkgs && sudo darwin-rebuild switch --flake .# && popd";

                    bedrock-token="source /Users/dorukakinci/Git/bedrock-token-generator/get-bedrock-token.sh";
                };
                initContent = ''
                   export PATH=/opt/homebrew/bin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:/run/current-system/sw/bin:/Users/dorukakinci/.local/bin:$PATH
                   export EDITOR=nvim
                   export VISUAL=nvim
                   eval "$(github-copilot-cli alias zsh)"
                   [[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
                '';
                oh-my-zsh = {
                    enable = true;
                    plugins = [
                        "aws"
                        "vi-mode"
                        "copypath"
                        "z"
                    ];
                };

                zplug = {
                    enable = true;
                    plugins = [
                        { name = "plugins/colored-man-pages"; tags = [from:oh-my-zsh]; }
                        { name = "plugins/command-not-found"; tags = [from:oh-my-zsh]; }
                    ];
                };
            };

            fzf = {
                enable = true;
                enableZshIntegration = true;
                colors = {
                    fg = dracula.fg;
                    bg = dracula.bg;
                    hl = dracula.purple;
                    "fg+" = dracula.fg;
                    "bg+" = dracula.selection;
                    "hl+" = dracula.purple;
                    info = dracula.orange;
                    prompt = dracula.green;
                    pointer = dracula.pink;
                    marker = dracula.pink;
                    spinner = dracula.orange;
                    header = dracula.comment;
                };
            };

            lsd = {
                enable = true;
            };

            desktoppr = {
                enable = true;
                settings.picture = ./dotfiles/nix/module/wallpaper/dracula-macos.png;
            };

            powerline-go = {
                enable = true;
                settings = {
                    hostname-only-if-ssh = true;
                    numeric-exit-codes = true;
                };
                modules = [
                    "venv"
                    "user"
                    "host"
                    "ssh"
                    "cwd"
                    "perms"
                    "git"
                    "hg"
                    "jobs"
                    "exit"
                ];
            };

            ghostty = {
                enable = true;
                package = null; # installed via homebrew (nixpkgs doesn't support darwin)
                settings = {
                    theme = "Dracula+";
                    background = "#000000";
                    font-size = 15;
                    clipboard-paste-protection = false;
                    keybind = [
                        "shift+enter=text:\\x1b\\r"
                        "cmd+c=copy_to_clipboard"
                        "cmd+v=paste_from_clipboard"
                    ];
                };
            };

            alacritty = {
                enable = true;
                settings = {
                    live_config_reload = true;
                    use_thin_strokes = true; ## defaults write org.alacritty AppleFontSmoothing -int 0

                    # use better window sizes for 2k monitor.
                    window = {
                        dimensions = {
                            columns = 125;
                            lines = 40;
                        };
                    };

                    font = {
                        size = 17;
                        normal = { family = "FiraCode Nerd Font"; style = "Regular";};
                        bold = { family = "FiraCode Nerd Font"; style = "Bold";};
                        italic = { family = "FiraCode Nerd Font"; style = "Italic";};
                    };
                    env = {
                        TERM = "xterm-256color";
                    };

                    colors = {
                        primary = {
                            background = dracula.bg;
                            foreground = dracula.fg;
                            bright_foreground = dracula.brightWhite;
                        };
                        cursor = {
                            text = "CellBackground";
                            cursor = "CellForeground";
                        };
                        vi_mode_cursor = {
                            text = "CellBackground";
                            cursor = "CellForeground";
                        };
                        search = {
                            matches = {
                                foreground = dracula.selection;
                                background = dracula.green;
                            };
                            focused_match = {
                                foreground = dracula.selection;
                                background = dracula.orange;
                            };
                        };
                        footer_bar = {
                            background = dracula.bg;
                            foreground = dracula.fg;
                        };
                        hints = {
                            start = {
                                foreground = dracula.bg;
                                background = dracula.yellow;
                            };
                            end = {
                                foreground = dracula.yellow;
                                background = dracula.bg;
                            };
                        };
                        line_indicator = {
                            foreground = "None";
                            background = "None";
                        };
                        selection = {
                            text = "CellForeground";
                            background = dracula.selection;
                        };
                        normal = {
                            black = dracula.darkBg;
                            red = dracula.red;
                            green = dracula.green;
                            yellow = dracula.yellow;
                            blue = dracula.purple;
                            magenta = dracula.pink;
                            cyan = dracula.cyan;
                            white = dracula.fg;
                        };
                        bright = dracula.bright;
                    };

                    mouse_bindings = [
                        { mouse = "Middle"; mode = "~Vi"; action = "PasteSelection"; }
                    ];

                    ## keyboard maps
                    key_bindings = [
                        { key = "V"; mods = "Command"; action = "Paste"; }
                        { key = "C"; mods = "Command"; action = "Copy"; }
                        { key = "H"; mods = "Command"; action = "Hide"; }
                        { key = "Q"; mods = "Command"; action = "Quit"; }
                        { key = "W"; mods = "Command"; action = "Quit"; }

                        { key = "Left"; mods = "Alt"; chars = ''\x1bb''; }
                        { key = "Right"; mods = "Alt"; chars = ''\x1bf''; }
                        { key = "Left"; mods = "Command"; chars = ''\x1bOH''; mode = "AppCursor"; }
                        { key = "Right"; mods = "Command"; chars = ''\x1bOF''; mode = "AppCursor"; }
                        { key = "Back"; mods = "Command"; chars = ''\x15''; }
                        { key = "Back"; mods = "Alt"; chars = ''\x1b\x7f''; }
                    ];
                };
            };
        };

        home.file.".hammerspoon" = {
            source = ./dotfiles/hammerspoon;
            recursive = true;
        };

        home.file.".raycast" = {
            source = ./dotfiles/raycast;
            recursive = true;
        };
    };
}
