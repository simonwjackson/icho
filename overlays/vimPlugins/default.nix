{
  codecompanion-nvim,
  channels,
  cmp-buffer,
  cmp-calc,
  cmp-cmdline,
  cmp-emoji,
  cmp-npm,
  cmp-nvim-lsp,
  cmp-nvim-lsp-signature-help,
  cmp-nvim-lua,
  cmp-path,
  cmp-spell,
  cmp-treesitter,
  cmp_luasnip,
  detour,
  git-worktree-nvim,
  lspkind-nvim,
  m_taskwarriror_d,
  middleclass,
  nvim-osc52,
  ripgrep,
  tree-sitter-just,
  vim-dadbod,
  vim-dadbod-completion,
  vim-dadbod-ui,
  # vim-expand-region,
  vim-highlightedyank,
  vim-visual-star-search,
  ...
}: final: prev: {
  vimPlugins =
    prev.vimPlugins
    // {
      m_taskwarriror_d = prev.vimUtils.buildVimPlugin {
        name = baseNameOf m_taskwarriror_d;
        src = m_taskwarriror_d;
      };

      codecompanion-nvim = prev.vimUtils.buildVimPlugin {
        name = baseNameOf codecompanion-nvim;
        src = codecompanion-nvim;
      };

      detour = prev.vimUtils.buildVimPlugin {
        name = baseNameOf detour;
        src = detour;
      };

      tree-sitter-just = prev.vimUtils.buildVimPlugin {
        name = baseNameOf tree-sitter-just;
        src = tree-sitter-just;
      };

      vim-dadbod-ui = prev.vimUtils.buildVimPlugin {
        name = baseNameOf vim-dadbod-ui;
        src = vim-dadbod-ui;
      };

      vim-dadbod = prev.vimUtils.buildVimPlugin {
        name = baseNameOf vim-dadbod;
        src = vim-dadbod;
      };

      middleclass = prev.vimUtils.buildVimPlugin {
        name = baseNameOf middleclass;
        src = middleclass;
      };

      vim-visual-star-search = prev.vimUtils.buildVimPlugin {
        name = baseNameOf vim-visual-star-search;
        src = vim-visual-star-search;
      };

      # vim-expand-region = prev.vimUtils.buildVimPlugin {
      #   name = baseNameOf vim-expand-region;
      #   src = vim-expand-region;
      # };
      #
      cmp_luasnip = prev.vimUtils.buildVimPlugin {
        name = baseNameOf cmp_luasnip;
        src = cmp_luasnip;
      };

      cmp-nvim-lsp = prev.vimUtils.buildVimPlugin {
        name = baseNameOf cmp-nvim-lsp;
        src = cmp-nvim-lsp;
      };

      cmp-nvim-lua = prev.vimUtils.buildVimPlugin {
        name = baseNameOf cmp-nvim-lua;
        src = cmp-nvim-lua;
      };

      cmp-buffer = prev.vimUtils.buildVimPlugin {
        name = baseNameOf cmp-buffer;
        src = cmp-buffer;
      };

      cmp-path = prev.vimUtils.buildVimPlugin {
        name = baseNameOf cmp-path;
        src = cmp-path;
      };

      cmp-cmdline = prev.vimUtils.buildVimPlugin {
        name = baseNameOf cmp-cmdline;
        src = cmp-cmdline;
      };

      cmp-nvim-lsp-signature-help = prev.vimUtils.buildVimPlugin {
        name = baseNameOf cmp-nvim-lsp-signature-help;
        src = cmp-nvim-lsp-signature-help;
      };

      cmp-treesitter = prev.vimUtils.buildVimPlugin {
        name = baseNameOf cmp-treesitter;
        src = cmp-treesitter;
      };

      cmp-spell = prev.vimUtils.buildVimPlugin {
        name = baseNameOf cmp-spell;
        src = cmp-spell;
      };

      cmp-emoji = prev.vimUtils.buildVimPlugin {
        name = baseNameOf cmp-emoji;
        src = cmp-emoji;
      };

      cmp-calc = prev.vimUtils.buildVimPlugin {
        name = baseNameOf cmp-calc;
        src = cmp-calc;
      };

      cmp-npm = prev.vimUtils.buildVimPlugin {
        name = baseNameOf cmp-npm;
        src = cmp-npm;
      };

      vim-dadbod-completion = prev.vimUtils.buildVimPlugin {
        name = baseNameOf vim-dadbod-completion;
        src = vim-dadbod-completion;
      };

      fd = prev.buildPackages.fd;

      ripgrep = prev.vimUtils.buildVimPlugin {
        name = baseNameOf ripgrep;
        src = ripgrep;
      };

      vim-highlightedyank = prev.vimUtils.buildVimPlugin {
        name = baseNameOf vim-highlightedyank;
        src = vim-highlightedyank;
      };

      lspkind-nvim = prev.vimUtils.buildVimPlugin {
        name = baseNameOf lspkind-nvim;
        src = lspkind-nvim;
      };

      git-worktree-nvim = prev.vimUtils.buildVimPlugin {
        name = baseNameOf git-worktree-nvim;
        src = git-worktree-nvim;
      };

      nvim-osc52 = prev.vimUtils.buildVimPlugin {
        name = baseNameOf nvim-osc52;
        src = nvim-osc52;
      };
    };
}
