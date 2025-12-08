{ pkgs, ... }: {
  globals.mapleader = " ";
  globals.maplocalleader = " ";

  # Liquid template support
  extraPlugins = [ pkgs.vimPlugins.vim-liquid ];

  # Always show sign column to prevent text shifting
  opts.signcolumn = "yes";

  # Default indentation: 2 spaces
  opts.tabstop = 2;
  opts.shiftwidth = 2;
  opts.softtabstop = 2;
  opts.expandtab = true;

  # Split behavior
  opts.splitkeep = "screen";  # keeps same screen lines in all split windows
  opts.splitbelow = true;
  opts.splitright = true;

  # Style the window separators
  highlightOverride = {
    WinSeparator = { fg = "#3b4261"; bg = "none"; };
  };

  extraConfigLua = ''
    vim.opt.fillchars = {
      eob = " ",           -- hide ~ at end of buffer
      fold = " ",          -- space for folds
      foldopen = "▾",      -- open fold marker
      foldclose = "▸",     -- closed fold marker
      foldsep = " ",       -- fold separator
      diff = "╱",          -- diagonal for deleted lines in diff
      vert = "│",          -- vertical window separator (thin)
      horiz = "─",         -- horizontal window separator (thin)
      horizup = "┴",
      horizdown = "┬",
      vertleft = "┤",
      vertright = "├",
      verthoriz = "┼",
    }

    -- Ctrl-S to save (only if modified)
    vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<Cmd>update<CR>", { desc = "Save" })

    -- Liquid template filetype detection
    vim.filetype.add({
      extension = {
        liquid = 'liquid',
      },
      pattern = {
        ['.*%.ts%.liquid'] = 'liquid',
        ['.*%.tsx%.liquid'] = 'liquid',
        ['.*%.js%.liquid'] = 'liquid',
        ['.*%.jsx%.liquid'] = 'liquid',
        ['.*%.nix%.liquid'] = 'liquid',
        ['.*%.json%.liquid'] = 'liquid',
        ['.*%.html%.liquid'] = 'liquid',
        ['.*%.css%.liquid'] = 'liquid',
        ['.*%.md%.liquid'] = 'liquid',
      },
    })
  '';
}
