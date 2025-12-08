{
  globals.mapleader = " ";
  globals.maplocalleader = " ";

  # Always show sign column to prevent text shifting
  opts.signcolumn = "yes";

  # Default indentation: 2 spaces
  opts.tabstop = 2;
  opts.shiftwidth = 2;
  opts.softtabstop = 2;
  opts.expandtab = true;

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
  '';
}
