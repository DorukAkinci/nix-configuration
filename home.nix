# `username` comes from flake.nix specialArgs — it differs per machine.
{ config, lib, pkgs, username, ... }:
let homeDir = "/Users/${username}";
in {
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  # A fresh Mac already has a stock ~/.zshrc etc. Without this, the FIRST
  # switch on a new machine aborts with "Existing file ... would be clobbered".
  # Renames the offender to <file>.backup instead of failing.
  home-manager.backupFileExtension = "backup";
  home-manager.users.${username} = { pkgs, lib, config, ... }:
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
      home.username = username;
      home.homeDirectory = homeDir;

      # Make bun reachable for PAI hook subprocesses (non-interactive shells)
      home.sessionPath = [ "$HOME/.bun/bin" ];

      # Disable app copying (blocked by company MDM)
      targets.darwin.copyApps.enable = false;
      # Show battery percentage in menu bar
      targets.darwin.currentHostDefaults."com.apple.controlcenter".BatteryShowPercentage =
        true;

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
            git = "LANG=en_US git";
            LANG = "en_US.UTF-8";
            LANG_ALL = "en_US.UTF-8";
            # ls, ll, la, lt, lla, llt are provided by lsd module
            coffee = "caffeinate -u -t 43200";
            desktop-hide =
              "defaults write com.apple.finder CreateDesktop -bool false && killall Finder";
            desktop-show =
              "defaults write com.apple.finder CreateDesktop -bool true && killall Finder";
            repo = "cd ~/Git";

            ssh-add-dorukakinci = "ssh-add ~/.ssh/kp_dorukakinci.pem";
            ssh-add-work = "ssh-add ~/.ssh/work.ssh";

            nix-switch =
              "pushd ~/.nixpkgs && sudo darwin-rebuild switch --flake .# && popd";

            bedrock-token =
              "source ${homeDir}/Git/bedrock-token-generator/get-bedrock-token.sh";
            claude-bedrock =
              "source ${homeDir}/Git/bedrock-token-generator/claude-bedrock.sh";
            claude-personal =
              "env -u AWS_BEARER_TOKEN_BEDROCK -u CLAUDE_CODE_USE_BEDROCK -u AWS_REGION claude";
            claude-yolo = "claude --dangerously-skip-permissions";
            # Jump to the PAI repo and launch the assistant from there.
            # Inside cmux -> cmux claude-teams (teammate panes render as splits);
            # bare terminal -> plain claude (no shim noise, no missing-session error).
            pai =
              "cd ~/.claude && { [ -n \"$CMUX_WORKSPACE_ID\" ] && cmux claude-teams --dangerously-skip-permissions || claude --dangerously-skip-permissions; }";
          };
          initContent = ''
            # ~/.local/bin before homebrew: native installs (claude) must shadow brew copies
            export PATH=/etc/profiles/per-user/${username}/bin:${homeDir}/.local/bin:/opt/homebrew/bin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:/run/current-system/sw/bin:$PATH
            export EDITOR=nvim
            export VISUAL=nvim
            export GPG_TTY=$(tty)
            # deprecated 2023 preview CLI — only present on #1 as an npm global; guard so
            # machines without it don't error on every new shell
            command -v github-copilot-cli >/dev/null && eval "$(github-copilot-cli alias zsh)"

            # Granted - AWS SSO profile switcher
            alias assume="source assume"

            # Ghostty shell integration, guarded on the script actually existing.
            # Ghostty.app ships it (sourced); cmux sets GHOSTTY_RESOURCES_DIR to a
            # bundle without it (skipped cleanly, no error).
            if [[ -r "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration" ]]; then
              source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
            fi
          '';
          oh-my-zsh = {
            enable = true;
            plugins = [ "aws" "vi-mode" "copypath" "z" ];
          };

          zplug = {
            enable = true;
            plugins = [
              {
                name = "plugins/colored-man-pages";
                tags = [ "from:oh-my-zsh" ];
              }
              {
                name = "plugins/command-not-found";
                tags = [ "from:oh-my-zsh" ];
              }
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

        lsd = { enable = true; };

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
          # HM's auto-injected zsh integration guards only on GHOSTTY_RESOURCES_DIR
          # being set, not on the script existing. cmux (libghostty) sets that var
          # to its own bundle, which ships no shell-integration script -> source
          # errors. Disable the auto-inject; a file-existence-guarded source is
          # added in programs.zsh.initContent instead.
          enableZshIntegration = false;
          package =
            null; # installed via homebrew (nixpkgs doesn't support darwin)
          settings = {
            theme = "Dracula+";
            background = "#000000";
            font-size = 15;
            clipboard-paste-protection = false;
            # Skip tmux inside cmux (it sets CMUX_SURFACE_ID): cmux owns
            # tabs/panes/session-restore and reads OSC 777/99 notifications
            # directly — a nested tmux would trap those escapes. Also avoid
            # tmux-in-tmux nesting. Ghostty.app (no CMUX_SURFACE_ID) -> tmux.
            command = "/bin/zsh -l -c 'if [ -z \"$TMUX\" ] && [ -z \"$CMUX_SURFACE_ID\" ]; then exec tmux; fi; exec /bin/zsh -i'";
            keybind = [
              "shift+enter=text:\\x1b\\r"
              "cmd+c=copy_to_clipboard"
              "cmd+v=paste_from_clipboard"
            ];
          };
        };

        tmux = {
          enable = true;
          shell = "/bin/zsh";
          terminal = "tmux-256color";
          prefix = "C-b";
          mouse = true;
          keyMode = "vi";
          baseIndex = 1;
          escapeTime = 0;
          historyLimit = 50000;

          plugins = with pkgs.tmuxPlugins; [
            {
              plugin = sensible;
              extraConfig = ''
                # Set PATH before any plugin scripts run
                set-environment -g PATH "/etc/profiles/per-user/${username}/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
              '';
            }
            open
            {
              plugin = catppuccin;
              extraConfig = ''
                # Theme flavor
                set -g @catppuccin_flavor 'mocha'

                # Window styling
                set -g @catppuccin_window_status_style 'rounded'
                set -g @catppuccin_window_number_position 'left'
                set -g @catppuccin_window_default_text '#W'
                set -g @catppuccin_window_current_text '#W'

                # Custom module settings
                set -g @catppuccin_date_time_text '%H:%M  %d-%b'
              '';
            }
          ];

          extraConfig = ''
            # Override sensible's default-command (it uses /bin/sh)
            set -g default-command "/bin/zsh"

            # Pass window titles through to Ghostty
            set -g set-titles on
            set -g set-titles-string '#S:#W — #{pane_current_path}'

            # Enable clickable hyperlinks (OSC 8) passthrough to Ghostty
            set -as terminal-features 'xterm-ghostty:hyperlinks'
            set -g allow-passthrough on

            # Enable true color and undercurl support
            set -ag terminal-overrides ",xterm-256color:RGB"
            set -ag terminal-overrides ",xterm-ghostty:RGB"
            set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
            set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

            # splits and new windows keep current directory
            bind | split-window -h -c "#{pane_current_path}"
            bind - split-window -v -c "#{pane_current_path}"
            bind c new-window -c "#{pane_current_path}"

            # reload config
            unbind r
            bind r source-file ~/.config/tmux/tmux.conf

            # navigate panes with prefix + hjkl
            bind h select-pane -L
            bind j select-pane -D
            bind k select-pane -U
            bind l select-pane -R

            # resize panes with alt + hjkl
            bind -n M-h resize-pane -L 5
            bind -n M-j resize-pane -D 5
            bind -n M-k resize-pane -U 5
            bind -n M-l resize-pane -R 5

            # pane borders - Catppuccin mocha colors
            set -g pane-border-style 'fg=#313244'
            set -g pane-active-border-style 'fg=#f38ba8,bold'
            set -g pane-border-lines heavy

            # vim-style copy mode
            bind -T copy-mode-vi v send -X begin-selection
            bind -T copy-mode-vi y send -X copy-selection-and-cancel

            # quick window switching with Alt + number
            bind -n M-1 select-window -t 1
            bind -n M-2 select-window -t 2
            bind -n M-3 select-window -t 3
            bind -n M-4 select-window -t 4
            bind -n M-5 select-window -t 5

            # Status bar position
            set -g status-position bottom
            set -g status-right-length 100
            set -g status-left-length 100

            # Status bar using catppuccin modules (v2 syntax)
            set -g status-left "#{E:@catppuccin_status_session}"
            set -g status-right "#{E:@catppuccin_status_directory}"
            set -ag status-right "#{E:@catppuccin_status_uptime}"
            set -ag status-right "#{E:@catppuccin_status_date_time}"
          '';
        };

        alacritty = {
          enable = true;
          settings = {
            live_config_reload = true;
            use_thin_strokes =
              true; # # defaults write org.alacritty AppleFontSmoothing -int 0

            # use better window sizes for 2k monitor.
            window = {
              dimensions = {
                columns = 125;
                lines = 40;
              };
            };

            font = {
              size = 17;
              normal = {
                family = "FiraCode Nerd Font";
                style = "Regular";
              };
              bold = {
                family = "FiraCode Nerd Font";
                style = "Bold";
              };
              italic = {
                family = "FiraCode Nerd Font";
                style = "Italic";
              };
            };
            env = { TERM = "xterm-256color"; };

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

            mouse_bindings = [{
              mouse = "Middle";
              mode = "~Vi";
              action = "PasteSelection";
            }];

            ## keyboard maps
            key_bindings = [
              {
                key = "V";
                mods = "Command";
                action = "Paste";
              }
              {
                key = "C";
                mods = "Command";
                action = "Copy";
              }
              {
                key = "H";
                mods = "Command";
                action = "Hide";
              }
              {
                key = "Q";
                mods = "Command";
                action = "Quit";
              }
              {
                key = "W";
                mods = "Command";
                action = "Quit";
              }

              {
                key = "Left";
                mods = "Alt";
                chars = "\\x1bb";
              }
              {
                key = "Right";
                mods = "Alt";
                chars = "\\x1bf";
              }
              {
                key = "Left";
                mods = "Command";
                chars = "\\x1bOH";
                mode = "AppCursor";
              }
              {
                key = "Right";
                mods = "Command";
                chars = "\\x1bOF";
                mode = "AppCursor";
              }
              {
                key = "Back";
                mods = "Command";
                chars = "\\x15";
              }
              {
                key = "Back";
                mods = "Alt";
                chars = "\\x1b\\x7f";
              }
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
