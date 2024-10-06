{
  description = "A bespoke neovim workspace. Powered by lua and nix.";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-frost = {
      url = "github:snowfallorg/frost";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim plugins
    codecompanion-nvim = {
      url = "github:olimorris/codecompanion.nvim";
      flake = false;
    };

    awesome-neovim-plugins.url = "github:m15a/flake-awesome-neovim-plugins";

    m_taskwarriror_d = {
      url = "github:simonwjackson/m_taskwarrior_d.nvim";
      flake = false;
    };

    tree-sitter-just = {
      url = "github:IndianBoy42/tree-sitter-just";
      flake = false;
    };

    detour = {
      url = "github:carbon-steel/detour.nvim";
      flake = false;
    };

    middleclass = {
      url = "github:anuvyklack/middleclass";
      flake = false;
    };

    vim-visual-star-search = {
      url = "github:nelstrom/vim-visual-star-search";
      flake = false;
    };

    edgy-nvim = {
      url = "github:folke/edgy.nvim";
      flake = false;
    };

    cmp_luasnip = {
      url = "github:saadparwaiz1/cmp_luasnip";
      flake = false;
    };

    cmp-nvim-lsp = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };

    cmp-nvim-lua = {
      url = "github:hrsh7th/cmp-nvim-lua";
      flake = false;
    };

    cmp-buffer = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };

    cmp-path = {
      url = "github:hrsh7th/cmp-path";
      flake = false;
    };

    cmp-cmdline = {
      url = "github:hrsh7th/cmp-cmdline";
      flake = false;
    };

    cmp-nvim-lsp-signature-help = {
      url = "github:hrsh7th/cmp-nvim-lsp-signature-help";
      flake = false;
    };

    cmp-treesitter = {
      url = "github:ray-x/cmp-treesitter";
      flake = false;
    };

    cmp-spell = {
      url = "github:f3fora/cmp-spell";
      flake = false;
    };

    cmp-emoji = {
      url = "github:hrsh7th/cmp-emoji";
      flake = false;
    };

    cmp-calc = {
      url = "github:hrsh7th/cmp-calc";
      flake = false;
    };

    cmp-npm = {
      url = "github:David-Kunz/cmp-npm";
      flake = false;
    };

    git-worktree-nvim = {
      # HACK: temporary fix to support telescope@0.1.6
      url = "github:awerebea/git-worktree.nvim?ref=handle_changes_in_telescope_api";
      # url = "github:ThePrimeagen/git-worktree.nvim";
      flake = false;
    };

    nvim-osc52 = {
      url = "github:ojroques/nvim-osc52";
      flake = false;
    };

    ripgrep = {
      url = "github:BurntSushi/ripgrep";
      flake = false;
    };

    fd = {
      url = "github:sharkdp/fd";
      flake = false;
    };

    vim-dadbod-ui = {
      url = "github:kristijanhusak/vim-dadbod-ui";
      flake = false;
    };

    vim-dadbod = {
      url = "github:tpope/vim-dadbod";
      flake = false;
    };

    vim-highlightedyank = {
      url = "github:machakann/vim-highlightedyank";
      flake = false;
    };

    lspkind-nvim = {
      url = "github:onsails/lspkind.nvim";
      flake = false;
    };

    vim-dadbod-completion = {
      url = "github:kristijanhusak/vim-dadbod-completion";
      flake = false;
    };
  };

  outputs = inputs: let
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;
    };
  in
    lib.mkFlake {
      overlays = [
        inputs.awesome-neovim-plugins.overlays.default
      ];

      channels-config = {
        allowUnfree = true;
      };

      snowfall = {
        namespace = "icho";

        meta = {
          name = "icho";
          title = "icho";
        };
      };

      alias = {
        packages = {
          default = "icho";
        };
      };
    }
    // {
      checks = {
        # system-wide = pkgs.callPackage ./tests/nixosModuleTest-system-wide.nix {
        #   inherit pkgs;
        # };
        # single-user = pkgs.callPackage ./tests/nixosModuleTest-single-user.nix {
        #   inherit pkgs;
        # };
      };
    };
}
