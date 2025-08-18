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
    tabby-nvim = {
      url = "github:nanozuki/tabby.nvim";
      flake = false;
    };
    claude-code-nvim = {
      url = "github:simonwjackson/claude-code.nvim/custom";
      flake = false;
    };
    edgy-nvim = {
      url = "github:folke/edgy.nvim";
      flake = false;
    };
    resession-nvim = {
      url = "github:stevearc/resession.nvim";
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
                  tabby-nvim = final.vimUtils.buildVimPlugin {
                    name = "tabby-nvim";
                    src = inputs.tabby-nvim;
                  };
                  claude-code-nvim = final.vimUtils.buildVimPlugin {
                    name = "claude-code-nvim";
                    src = inputs.claude-code-nvim;
                  };
                  edgy-nvim = final.vimUtils.buildVimPlugin {
                    name = "edgy-nvim";
                    src = inputs.edgy-nvim;
                  };
                  overseer-nvim = final.vimUtils.buildVimPlugin {
                    name = "overseer-nvim";
                    src = inputs.vim-overseer;
                    doCheck = false;
                  };
                  resession-nvim = final.vimUtils.buildVimPlugin {
                    name = "resession-nvim";
                    src = inputs.resession-nvim;
                  };
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
