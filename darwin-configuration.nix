### darwin-rebuild switch
# Home manager and Flakes support will be added later #

{ config, pkgs, lib, ... }:

{
  users.users.dorukakinci.home = "/Users/dorukakinci";
  
  system = {
    defaults = {
      NSGlobalDomain = {
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        AppleTemperatureUnit = "Celsius";
        AppleMeasurementUnits = "Centimeters";
        AppleICUForce24HourTime = true;
      };

      ActivityMonitor = {
        ShowCategory = 100;
        SortColumn = "CPUUsage";
        SortDirection = 0;
      };

      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
      };

      dock.autohide = false;
      trackpad.TrackpadThreeFingerDrag = true;
    };

    keyboard = {
      enableKeyMapping = true;
      nonUS.remapTilde = true;
    };
  };

  security.pam.enableSudoTouchIdAuth = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
      vim
      curl
      tree
      htop
      unixtools.watch.out
      wget
      fzf
      jq
      yq
      just
      ripgrep
      dhall
      awscli2
      k9s
      kubectl
      krew # krew install whoami  ## will be configured with a proper `nix flake` later 
      minikube
      kubernetes-helm
      argocd
      terraform
      tfk8s
      tflint
      tfsec
    ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Enable experimental nix command and flakes
  # nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
    '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  programs.zsh.enableBashCompletion = true;
  programs.zsh.enableFzfCompletion = true;
  programs.zsh.enableFzfGit = true;
  programs.zsh.enableFzfHistory = true;
  programs.zsh.enableSyntaxHighlighting = true;

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    casks = [
      "visual-studio-code"
      "docker"
      "flameshot"
      "keepassxc"
      "leapp"
      "notion"
      "hiddenbar"
      "iterm2"
      "disk-inventory-x"
      "slack"
      "clickup"
      "gpg-suite"
      "fork"
      "quik" # gopro
      "hammerspoon" # macos automation 
      "raycast" # Spotlight alternative
      "hyperkey" # Use your capslock key as a modifier
    ];
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
