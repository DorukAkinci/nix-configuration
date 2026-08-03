{
  description = "DorukAkinci's Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # nix will normally use the nixpkgs defined in home-managers inputs, we only want one copy of nixpkgs though
    darwin.url = "github:lnl7/nix-darwin/nix-darwin-25.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs"; # ...
  };

  # add the inputs declared above to the argument attribute set
  outputs = { self, nixpkgs, home-manager, darwin, unstable }:
    let
      # ── Every Mac managed by this flake ──────────────────────────────────
      # Adding a machine is ONE line here. Each host is built from the exact
      # same modules (darwin-configuration.nix + home.nix), so the machines
      # stay in lockstep by construction — hostname and account name are the
      # only inputs that differ. Build a specific host with:
      #   darwin-rebuild switch --flake ~/.nixpkgs#<HOSTNAME>
      hosts = {
        TRENGDOAKMAC = { username = "dorukakinci"; }; # MacBook #1

        # MacBook #2 — uncomment and set the real hostname on first bootstrap.
        # The account there is `doruk.akinci` (note the dot), not `dorukakinci`.
        # NEWHOSTNAME = { username = "doruk.akinci"; };
      };

      mkDarwin = hostname: { username }: darwin.lib.darwinSystem {
        system = "aarch64-darwin"; # "x86_64-darwin" if you're using a pre M1 mac
        specialArgs = { inherit hostname username; };
        modules = [
          # Machine identity is declarative too — nix owns the hostname.
          {
            networking.hostName = hostname;
            networking.computerName = hostname;
            networking.localHostName = hostname;
          }
          ./darwin-configuration.nix
          home-manager.darwinModules.home-manager
          ./home.nix
        ];
      };
    in
    {
      darwinConfigurations = nixpkgs.lib.mapAttrs mkDarwin hosts;
    };
}
