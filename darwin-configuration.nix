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

      CustomUserPreferences = {
        # Raycast reads its global hotkey from this key at launch; ⌘Space.
        "com.raycast.macos".raycastGlobalHotkey = "Command-49";

        # Hyperkey: caps lock → ⌘⌥⌃⇧ hyper modifier (parity with MacBook #1's
        # live config; Paddle license stays a one-time manual activation).
        # Keys observed on a v22 install — if a newer Hyperkey ignores them,
        # set it once in the UI and re-sync these from `defaults read`.
        "com.knollsoft.Hyperkey" = {
          keyRemap = 1; # remapping enabled
          capsLockRemapped = 2; # the remapped physical key = caps lock
          capsLockKeycode = "-1";
          hyperFlags = 1966080; # ⌘(0x100000)+⌥(0x80000)+⌃(0x40000)+⇧(0x20000)
          executeQuickHyperKey = 2;
          launchOnLogin = 1;
          hideMenuBarIcon = 1;
          SUEnableAutomaticChecks = 0;
        };
      };
    };

    keyboard = {
      enableKeyMapping = true;
      nonUS.remapTilde = true;
    };

    # Spotlight ⌘Space → ⌥⌘Space so Raycast can own ⌘Space.
    # Written with `-dict-add` instead of CustomUserPreferences because that
    # module replaces the whole AppleSymbolicHotKeys dict, wiping every other
    # hotkey entry on the machine.
    # 64 = "Show Spotlight search"; 65 = "Show Finder search window", whose
    # DEFAULT binding is ⌥⌘Space — it must be disabled to free the combo.
    # parameters = [ascii, keycode, modifiers]: 32/49 = space, 1572864 = ⌥⌘.
    activationScripts.postActivation.text = ''
      sudo -u ${username} defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 \
        "<dict><key>enabled</key><true/><key>value</key><dict><key>type</key><string>standard</string><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>1572864</integer></array></dict></dict>"
      sudo -u ${username} defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 \
        "<dict><key>enabled</key><false/><key>value</key><dict><key>type</key><string>standard</string><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>1572864</integer></array></dict></dict>"
      sudo -u ${username} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
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
    stern # k8s multi pod log tailing
    minikube
    kubernetes-helm
    argocd
    terraform
    tfk8s
    tflint
    tfsec
    gh # github cli
    glab # gitlab cli
    bun # JS runtime — PAI hooks + Pulse depend on it (was a per-machine native install)
    eksctl
    skopeo # container image copy/inspect between registries
    shellcheck
    shfmt
    pre-commit
    go
    pnpm
    yarn
    fd
    bat
    lsd
    rclone
    neovim
    nushell
    valkey
    mycli
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
      "gemini-cli" # `gemini` — Google Gemini CLI (Pollux lane; hand-installed on #1 before this)
      "gnu-sed" # home.nix PATH points at /opt/homebrew/opt/gnu-sed/libexec/gnubin
      "opencode" # AI coding agent CLI (fast-moving; brew matches #1)
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
      "cmux" # agent multiplexer app + CLI — primary Claude Code pane manager
      "copilot-cli" # GitHub Copilot CLI (`copilot`) — Forge's primary GPT lane
      "codex" # OpenAI Codex CLI — Forge's fallback GPT lane + Cato's audit path
      "antigravity-cli" # Google Antigravity CLI (`agy`) — agent terminal interface
      "chatgpt"
      "dbeaver-community"
      "tailscale-app" # upstream renamed the `tailscale` cask
      "obsidian"
      "wispr-flow" # voice dictation
      "yubico-authenticator"
      "zoom"
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
