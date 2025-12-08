{
  globals.mapleader = " ";
  globals.maplocalleader = " ";

  # Style the window separators
  highlightOverride = {
    WinSeparator = { fg = "#3b4261"; bg = "none"; };
  };

  extraConfigLua = ''
    -- Thin window separators
    vim.opt.fillchars = {
      horiz = "─",
      horizup = "┴",
      horizdown = "┬",
      vert = "│",
      vertleft = "┤",
      vertright = "├",
      verthoriz = "┼",
    }
  '';
}
