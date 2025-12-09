{pkgs, ...}: {
  extraPlugins = [
    pkgs.vimPlugins.heirline-nvim
  ];

  # Global statusline at bottom
  opts.laststatus = 3; # global statusline provides window separator
  opts.showtabline = 0; # hide tabline
  opts.showmode = false;
  opts.cmdheight = 0; # hide cmdline when not in use

  # Add our lua files to the runtime path
  extraFiles = {
    "lua/heirline/colors.lua".source = ./heirline/colors.lua;
    "lua/heirline/components.lua".source = ./heirline/components.lua;
    "lua/heirline/claude_usage.lua".source = ./heirline/claude_usage.lua;
  };

  extraConfigLua = ''
    local conditions = require("heirline.conditions")
    local utils = require("heirline.utils")
    local colors = require("heirline.colors")
    local c = require("heirline.components")

    -- Load colors
    require("heirline").load_colors(colors.setup)

    -- Update colors on colorscheme change
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        utils.on_colorscheme(colors.setup)
      end,
      group = vim.api.nvim_create_augroup("Heirline", { clear = true }),
    })

    ---------------------------------------------------------------------------
    -- Upside-down Tab Separators (using lower triangles)
    ---------------------------------------------------------------------------

    -- Characters needed (you'll add manually):
    --   TAB_LEFT = "" (U+E0BA, lower-left triangle)
    --   TAB_RIGHT = "" (U+E0BC, lower-right triangle)
    -- Creates tabs that appear to point downward/come from above

    local TAB_LEFT = "◣"   -- MANUAL: replace with U+E0BA
    local TAB_RIGHT = "◢"  -- MANUAL: replace with U+E0BC

    -- Helper to check if in a git repo (any branch)
    local function has_visible_branch()
      local handle = io.popen("git branch --show-current 2>/dev/null")
      if not handle then return false end
      local branch = handle:read("*a"):gsub("^%s*(.-)%s*$", "%1")
      handle:close()
      return branch ~= ""
    end

    -- Helper to check if claude usage is available
    local claude_usage = require("heirline.claude_usage")
    local function has_claude_usage()
      local data = claude_usage.get_usage_data()
      return data and data.seven_day
    end

    local function is_zoomed()
      return vim.g.zoom_win_active
    end

    local mode_hl_map = {
      n = "Function",     -- blue
      i = "String",       -- green
      v = "Special",      -- cyan
      V = "Special",
      ["\22"] = "Special",
      c = "Constant",     -- orange
      s = "Statement",    -- purple
      S = "Statement",
      ["\19"] = "Statement",
      R = "Constant",
      r = "Constant",
      ["!"] = "DiagnosticError",
      t = "String",
    }

    ---------------------------------------------------------------------------
    -- Left Side Segments
    ---------------------------------------------------------------------------

    -- WorkDir tab (only segment with tab styling)
    local WorkDirTabStart = {
      provider = TAB_LEFT,
      hl = { fg = "tabline_bg", bg = "seg_dir" },
    }
    local WorkDirTabEnd = {
      provider = TAB_RIGHT,
      hl = { fg = "tabline_bg", bg = "seg_dir" },
    }

    local LeftSegments = {
      c.Hostname,
      c.Space,
      -- WorkDir tab
      WorkDirTabStart,
      c.WorkDir,
      WorkDirTabEnd,
      c.GitBranch,
      c.Space,
      c.ViMode,
    }

    ---------------------------------------------------------------------------
    -- Right Side Segments
    ---------------------------------------------------------------------------

    -- Zoom tab (uses seg_dir for normal buffer bg)
    local ZoomTabStart = {
      condition = function() return vim.g.zoom_win_active end,
      provider = TAB_LEFT,
      hl = { fg = "tabline_bg", bg = "seg_dir" },
    }
    local ZoomTabEnd = {
      condition = function() return vim.g.zoom_win_active end,
      provider = TAB_RIGHT,
      hl = { fg = "tabline_bg", bg = "seg_dir" },
    }

    local RightSegments = {
      ZoomTabStart,
      c.ZoomIndicator,
      ZoomTabEnd,
      c.Space,
      c.Space,
      c.Space,
      c.ClaudeWeekly,
      c.Space,
      c.Space,
      c.Space,
      c.ClaudePace,
      c.Space,
      c.Space,
      c.Space,
      c.ClaudeBudget,
    }

    local TabLine = {
      LeftSegments,
      c.Align,
      RightSegments,
    }

    ---------------------------------------------------------------------------
    -- Statusline (same content as tabline was)
    ---------------------------------------------------------------------------

    local Statusline = {
      LeftSegments,
      c.Align,
      RightSegments,
    }

    ---------------------------------------------------------------------------
    -- Setup
    ---------------------------------------------------------------------------

    require("heirline").setup({
      statusline = Statusline,
    })
  '';
}
