{ config, lib, pkgs, ... }:
{
    home-manager.useUserPackages = true;
    home-manager.useGlobalPkgs = true;
    home-manager.users.dorukakinci = { pkgs, lib, config, ... }: {
        home.stateVersion = "22.11";
        home.username = "dorukakinci";
        home.homeDirectory = "/Users/dorukakinci";

        fonts.fontconfig.enable = true;

        home.packages = with pkgs; [
            (nerdfonts.override { fonts = [ "Meslo" ]; })
        ];

        programs.nix-index.enable = true;
        programs.nix-index.enableZshIntegration = true;

        programs = {
            zsh = {
                enable = true;
                autocd = true;
                dotDir = ".config/zsh";
                enableAutosuggestions = true;
                enableCompletion = true;
                shellAliases = {
                    ls="lsd";
                    l="ls -l";
                    ll="ls -la";
                    lt="ls --tree";
                    coffee="caffeinate -u -t 43200";
                    desktop-hide="defaults write com.apple.finder CreateDesktop -bool false && killall Finder";
                    desktop-show="defaults write com.apple.finder CreateDesktop -bool true && killall Finder";

                    repo="cd ~/Git";

                    ssh-add-dorukakinci="ssh-add ~/.ssh/kp_dorukakinci.pem";
                    ssh-add-work="ssh-add ~/.ssh/work.ssh";

                    nix-switch="pushd ~/.nixpkgs && darwin-rebuild switch --flake .# && popd";
                };
                initExtra = ''
                   export PATH=/opt/homebrew/bin:/run/current-system/sw/bin:$PATH  ### Homebrew and NIX paths
                   export EDITOR=vim
                '';
                plugins = with pkgs; [
                    # {
                    #     name = "zsh-syntax-highlighting";
                    #     src = pkgs.fetchFromGitHub {
                    #         owner = "zsh-users";
                    #         repo = "zsh-syntax-highlighting";
                    #         rev = "0.6.0";
                    #         sha256 = "0zmq66dzasmr5pwribyh4kbkk23jxbpdw4rjxx0i7dx8jjp2lzl4";
                    #     };
                    #     file = "zsh-syntax-highlighting.zsh";
                    # }
                ];
                oh-my-zsh = {
                    enable = true;
                    plugins = [
                        "aws"
                    ];
                };

                zplug = {
                    enable = true;
                    plugins = [
                        { name = "plugins/zsh-syntax-highlighting"; tags = [from:oh-my-zsh]; }
                        { name = "plugins/colored-man-pages"; tags = [from:oh-my-zsh]; }
                        { name = "plugins/command-not-found"; tags = [from:oh-my-zsh]; }
                    ];
                };
            };

            fzf = {
                enable = true;
                enableZshIntegration = true;
                # dracula color scheme
                colors = { 
                    fg = "#f8f8f2";
                    bg = "#282a36";
                    hl = "#bd93f9";
                    "fg+" = "#f8f8f2";
                    "bg+" = "#44475a";
                    "hl+" = "#bd93f9";
                    info = "#ffb86c";
                    prompt = "#50fa7b";
                    pointer = "#ff79c6";
                    marker = "#ff79c6";
                    spinner = "#ffb86c";
                    header = "#6272a4";
                };
            };

            lsd = {
                enable = true;
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
                        size = 16;
                        normal = { family = "MesloLGS NF"; style = "Regular";};
                        bold = { family = "MesloLGS NF"; style = "Bold";};
                        italic = { family = "MesloLGS NF"; style = "Italic";};
                    };
                    env = {
                        TERM = "xterm-256color";
                    };

                    # dracula color scheme
                    colors = {
                        primary = {
                            background = "#282a36";
                            foreground = "#f8f8f2";
                            bright_foreground = "#ffffff";
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
                                foreground = "#44475a";
                                background = "#50fa7b";
                            };
                            focused_match = {
                                foreground = "#44475a";
                                background = "#ffb86c";
                            };
                        };
                        footer_bar = {
                            background = "#282a36";
                            foreground = "#f8f8f2";
                        };
                        hints = {
                            start = {
                                foreground = "#282a36";
                                background = "#f1fa8c";
                            };
                            end = {
                                foreground = "#f1fa8c";
                                background = "#282a36";
                            };
                        };
                        line_indicator = {
                            foreground = "None";
                            background = "None";
                        };
                        selection = {
                            text = "CellForeground";
                            background = "#44475a";
                        };
                        normal = {
                            black = "#21222c";
                            red = "#ff5555";
                            green = "#50fa7b";
                            yellow = "#f1fa8c";
                            blue = "#bd93f9";
                            magenta = "#ff79c6";
                            cyan = "#8be9fd";
                            white = "#f8f8f2";
                        };
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

                        # vi
                        { key = "Left"; mods = "Alt"; mode = "Vi"; action = "WordLeft"; }
                        { key = "Right"; mods = "Alt";  mode = "Vi"; action = "WordRight"; }
                        { key = "Back"; mods = "Alt"; mode = "Vi"; action = "DeleteWordLeft"; }
                        { key = "Delete"; mods = "Alt"; mode = "Vi"; action = "DeleteWordRight"; }
                    ];
                };
            };
        };

        home.file."mytestfile".text = lib.generators.toYAML {} {
            templates = {
                scm-init = "git";
                params = {
                    author-name = "Your Name"; # config.programs.git.userName;
                    author-email = "youremail@example.com"; # config.programs.git.userEmail;
                    github-username = "yourusername";
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
        
        # osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"~/.nixpkgs/dotfiles/nix/module/wallpaper/dracula-macos.png\" as POSIX file"
    };
}