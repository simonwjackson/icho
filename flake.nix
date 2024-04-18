{
  description = "My own Neovim flake with plugins";
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs";
    };

    neovim = {
      url = "github:neovim/neovim/stable?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    lazy-nvim = {
      url = "github:folke/lazy.nvim";
      flake = false;
    };

    # (Neo)vim Plugins

    which-key = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };

    flash = {
      url = "github:folke/flash.nvim";
      flake = false;
    };

    code-companion = {
      url = "github:olimorris/codecompanion.nvim";
      flake = false;
    };
  };
  outputs = {
    self,
    nixpkgs,
    neovim,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              vimPlugins =
                prev.vimPlugins
                // {
                  lazy-nvim = prev.vimUtils.buildVimPlugin {
                    name = baseNameOf inputs.lazy-nvim;
                    src = inputs.lazy-nvim;
                  };
                  flash = prev.vimUtils.buildVimPlugin {
                    name = baseNameOf inputs.flash;
                    src = inputs.flash;
                  };
                  which-key = prev.vimUtils.buildVimPlugin {
                    name = baseNameOf inputs.which-key;
                    src = inputs.which-key;
                  };
                  code-companion = prev.vimUtils.buildVimPlugin {
                    name = baseNameOf inputs.code-companion;
                    src = inputs.code-companion;
                  };
                };
            })
          ];
        };

        plugins = pkgs.callPackage ./plugins.nix {};

        neovimConfig = pkgs.runCommandNoCC "neovimConfig" {} ''
          mkdir -p $out/nvim/lua
          cp -r ${self}/config/* $out/nvim/
          ln -s ${plugins}/* $out/nvim/lua
        '';

        neovimWrapped = let
          environment = import ./get-env-vars.nix {inherit pkgs;};
          environmentFiles = import ./get-env-files.nix {inherit pkgs;};
        in
          pkgs.writeShellScriptBin "nvim" ''
            export XDG_CONFIG_HOME="${neovimConfig}"

            ${environment}
            ${environmentFiles}

            ${neovim.packages.${system}.neovim}/bin/nvim "$@"
          '';
      in {
        packages.default = neovimWrapped;
        apps.default = {
          type = "app";
          program = "${neovimWrapped}/bin/nvim";
        };
      }
    );
}
