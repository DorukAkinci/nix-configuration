# `username` comes from flake.nix specialArgs — it differs per machine.
{ config, pkgs, lib, username, ... }:

{
  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";

  nixpkgs.config.allowUnfree = true;
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

      trackpad = { Clicking = false; };

      dock.autohide = false;
    };

    keyboard = {
      enableKeyMapping = true;
      nonUS.remapTilde = true;
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;

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
    #stern # k8s multi pod log tailing
    minikube
    kubernetes-helm
    argocd
    terraform
    tfk8s
    tflint
    tfsec
    gh # github cli
    bun # JS runtime — PAI hooks + Pulse depend on it (was a per-machine native install)
  ];

  # Enable experimental nix command and flakes
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '' + lib.optionalString
    (pkgs.stdenv.hostPlatform.system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';

  programs.zsh.enable = true;
  programs.zsh.enableBashCompletion = true;
  # fzf integration handled by home-manager (avoids conflict with modern fzf --zsh)
  programs.zsh.enableFzfCompletion = false;
  programs.zsh.enableFzfGit = false;
  programs.zsh.enableFzfHistory = false;

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    brews = [
      "rust"
      "rtk" # token-optimizing CLI proxy (homebrew-core; hand-installed on #1 before this)
    ];
    casks = [
      "visual-studio-code"
      "docker-desktop"
      "flameshot"
      "keepassxc"
      "leapp"
      "notion"
      "hiddenbar"
      "iterm2"
      "disk-inventory-x"
      "slack"
      "telegram"
      "clickup"
      "gpg-suite"
      "fork"
      # "quik" # gopro — cask discontinued upstream (brew: "No available formula"), 2026-08-03
      "hammerspoon" # macos automation
      "raycast" # Spotlight alternative
      "hyperkey" # Use your capslock key as a modifier
      "claude"
      "chatgpt"
      "dbeaver-community"
      "ghostty"
      "font-hack-nerd-font"
      "elgato-stream-deck"
      "microsoft-office"
    ];
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
