{
  globals.mapleader = " ";
  globals.maplocalleader = " ";

  # Style the window separators
  highlightOverride = {
    WinSeparator = { fg = "#3b4261"; bg = "none"; };
    # Hide the global statusline
    StatusLine = { bg = "none"; fg = "none"; };
    StatusLineNC = { bg = "none"; fg = "none"; };
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
      stl = " ",           -- statusline fill (space to hide)
      stlnc = " ",         -- inactive statusline fill
    }

    -- Set TabLineFill to a slightly darker shade than Normal bg
    local function darken(hex, factor)
      factor = factor or 0.85
      hex = hex:gsub("#", "")
      local r = math.floor(tonumber(hex:sub(1, 2), 16) * factor)
      local g = math.floor(tonumber(hex:sub(3, 4), 16) * factor)
      local b = math.floor(tonumber(hex:sub(5, 6), 16) * factor)
      return string.format("#%02x%02x%02x", r, g, b)
    end

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
        if normal_bg then
          local darker_bg = darken(string.format("#%06x", normal_bg), 0.85)
          vim.api.nvim_set_hl(0, "TabLineFill", { bg = darker_bg })
        end
      end,
      group = vim.api.nvim_create_augroup("TabLineDarker", { clear = true }),
    })

    -- Apply immediately for current colorscheme
    local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
    if normal_bg then
      local function darken_now(hex, factor)
        factor = factor or 0.85
        hex = hex:gsub("#", "")
        local r = math.floor(tonumber(hex:sub(1, 2), 16) * factor)
        local g = math.floor(tonumber(hex:sub(3, 4), 16) * factor)
        local b = math.floor(tonumber(hex:sub(5, 6), 16) * factor)
        return string.format("#%02x%02x%02x", r, g, b)
      end
      local darker_bg = darken_now(string.format("#%06x", normal_bg), 0.85)
      vim.api.nvim_set_hl(0, "TabLineFill", { bg = darker_bg })
    end
  '';
}
