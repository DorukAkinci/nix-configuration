{ config, lib, pkgs, ... }:
{
    # hosts/YourHostName/default.nix - inside the returning attribute set
    
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.dorukakinci = { pkgs, lib, config, ... }: {
        home.stateVersion = "22.11";
        home.username = "dorukakinci";
        #home.homeDirectory = "/Users/dorukakinci";
        home.packages = with pkgs; [
            
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
                };

                plugins = with pkgs; [
                    {
                        name = "zsh-syntax-highlighting";
                        src = pkgs.fetchFromGitHub {
                            owner = "zsh-users";
                            repo = "zsh-syntax-highlighting";
                            rev = "0.6.0";
                            sha256 = "0zmq66dzasmr5pwribyh4kbkk23jxbpdw4rjxx0i7dx8jjp2lzl4";
                        };
                        file = "zsh-syntax-highlighting.zsh";
                    }
                ];
                oh-my-zsh = {
                    enable = true;
                    plugins = [
                        "aws"
                    ];
                };
            };

            fzf = {
                enable = true;
                enableZshIntegration = true;
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
    };
}