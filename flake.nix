{
  description = "A nixvim configuration";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixvim.url = "github:nix-community/nixvim";
    vim-overseer = {
      url = "github:simonwjackson/overseer.nvim/custom";
      flake = false;
    };
    tmesh.url = "github:simonwjackson/tmesh";
  };

  outputs = {
    nixvim,
    flake-parts,
    nixpkgs,
    tmesh,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = {system, ...}: let
        pkgs = import nixpkgs {
          inherit system;
          # Allow unfree packages, specifically Claude Code
          config = {
            allowUnfreePredicate = pkg:
              builtins.elem (nixpkgs.lib.getName pkg) [
                "claude-code"
              ];
          };
          overlays = [
            (final: prev: {
              vimPlugins =
                prev.vimPlugins
                // {
                  tmux-session-switcher = tmesh.packages.${system}.tmux-session-switcher;
                };
            })
          ];
        };

        nixvimLib = nixvim.lib.${system};
        nixvim' = nixvim.legacyPackages.${system};
        nixvimModule = {
          inherit pkgs; # Now using our modified pkgs
          module = import ./config;
          extraSpecialArgs = {
            inherit inputs;
          };
        };
        nvim = nixvim'.makeNixvimWithModule nixvimModule;
      in {
        checks = {
          default = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;
        };

        packages = {
          default = nvim;
        };
      };
    };
}
