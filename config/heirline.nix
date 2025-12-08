{ pkgs, ... }:
{
  extraPlugins = [
    pkgs.vimPlugins.heirline-nvim
  ];

  # Global statusline (empty) + tabline at top
  opts.laststatus = 3; # global statusline prevents per-window separator lines
  opts.showtabline = 2; # always show tabline
  opts.showmode = false;

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
    -- Powerline Separators
    ---------------------------------------------------------------------------

    -- Left side separators (point right →)
    -- SepHostGit: same bg, use thin divider
    local SepHostGit = { provider = " │ ", hl = { fg = "gray" } }
    -- Removed SepHostEnd and SepGitEnd - no longer needed without bg contrast

    -- Right side separators (point left ←)
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

    local SepStartMode = {
      init = function(self)
        self.mode = vim.fn.mode(1)
      end,
      provider = "",
      hl = function(self)
        local mode = self.mode:sub(1, 1)
        local hl_group = mode_hl_map[mode] or "Function"
        local fg = utils.get_highlight(hl_group).fg
        return { fg = fg, bg = "none" }
      end,
    }
    local SepModeFile = {
      init = function(self)
        self.mode = vim.fn.mode(1)
      end,
      provider = "",
      hl = function(self)
        local mode = self.mode:sub(1, 1)
        local hl_group = mode_hl_map[mode] or "Function"
        local bg = utils.get_highlight(hl_group).fg
        return { fg = "seg_file", bg = bg }
      end,
    }
    local SepModeEnd = {
      init = function(self)
        self.mode = vim.fn.mode(1)
      end,
      provider = "",
      hl = function(self)
        local mode = self.mode:sub(1, 1)
        local hl_group = mode_hl_map[mode] or "Function"
        local fg = utils.get_highlight(hl_group).fg
        return { fg = fg, bg = "none" }
      end,
    }

    ---------------------------------------------------------------------------
    -- Tabline (single top bar)
    ---------------------------------------------------------------------------

    local SepHostMode = {
      init = function(self)
        self.mode = vim.fn.mode(1)
      end,
      provider = "",
      hl = function(self)
        local mode = self.mode:sub(1, 1)
        local hl_group = mode_hl_map[mode] or "Function"
        local bg = utils.get_highlight(hl_group).fg
        return { fg = "seg_host", bg = bg }
      end,
    }

    local SepModeGit = {
      init = function(self)
        self.mode = vim.fn.mode(1)
      end,
      provider = "",
      hl = function(self)
        local mode = self.mode:sub(1, 1)
        local hl_group = mode_hl_map[mode] or "Function"
        local fg = utils.get_highlight(hl_group).fg
        return { fg = fg, bg = "seg_git" }
      end,
    }

    local SepModeEnd = {
      init = function(self)
        self.mode = vim.fn.mode(1)
      end,
      provider = "",
      hl = function(self)
        local mode = self.mode:sub(1, 1)
        local hl_group = mode_hl_map[mode] or "Function"
        local fg = utils.get_highlight(hl_group).fg
        return { fg = fg, bg = "none" }
      end,
    }

    -- Helper to check if in a git repo (any branch)
    local function has_visible_branch()
      local handle = io.popen("git branch --show-current 2>/dev/null")
      if not handle then return false end
      local branch = handle:read("*a"):gsub("^%s*(.-)%s*$", "%1")
      handle:close()
      return branch ~= ""
    end

    local SepModeGitDynamic = {
      condition = has_visible_branch,
      init = function(self)
        self.mode = vim.fn.mode(1)
      end,
      provider = "",
      hl = function(self)
        local mode = self.mode:sub(1, 1)
        local hl_group = mode_hl_map[mode] or "Function"
        local fg = utils.get_highlight(hl_group).fg
        return { fg = fg, bg = "seg_git" }
      end,
    }

    local SepGitEndDynamic = {
      condition = has_visible_branch,
      provider = "",
      hl = { fg = "seg_git", bg = "none" },
    }

    local SepModeEndDynamic = {
      init = function(self)
        self.mode = vim.fn.mode(1)
      end,
      provider = "",
      hl = function(self)
        local mode = self.mode:sub(1, 1)
        local hl_group = mode_hl_map[mode] or "Function"
        local fg = utils.get_highlight(hl_group).fg
        return { fg = fg, bg = "none" }
      end,
    }

    -- Separator: Host -> WorkDir (thin divider)
    local SepHostDir = {
      provider = " │ ",
      hl = { fg = "dim" },
    }

    -- Separator: WorkDir -> Mode (thin divider)
    local SepDirMode = {
      provider = " │ ",
      hl = { fg = "dim" },
    }

    -- Separator: Mode -> end
    local SepModeEnd = {
      init = function(self)
        self.mode = vim.fn.mode(1)
      end,
      provider = "",
      hl = function(self)
        local mode = self.mode:sub(1, 1)
        local hl_group = mode_hl_map[mode] or "Function"
        local fg = utils.get_highlight(hl_group).fg
        return { fg = fg, bg = "none" }
      end,
    }

    local LeftSegments = {
      c.Hostname,
      SepHostDir,
      c.WorkDir,
      SepDirMode,
      c.ViMode,
    }

    local SepStartGit = {
      condition = has_visible_branch,
      provider = "",
      hl = { fg = "seg_git", bg = "none" },
    }

    ---------------------------------------------------------------------------
    -- Claude Usage Separators (right side, point left ←)
    ---------------------------------------------------------------------------

    -- Helper to check if claude usage is available
    local claude_usage = require("heirline.claude_usage")
    local function has_claude_usage()
      local data = claude_usage.get_usage_data()
      return data and data.seven_day
    end

    -- Separator between Weekly and Pace (thin divider)
    local SepWeeklyPace = {
      condition = has_claude_usage,
      provider = " │ ",
      hl = { fg = "dim" },
    }

    -- Separator between Pace and Budget (thin divider)
    local SepPaceBudget = {
      condition = has_claude_usage,
      provider = " │ ",
      hl = { fg = "dim" },
    }

    -- End separator after Budget - never used now since WorkDir always follows when no git
    local SepClaudeEnd = {
      condition = function()
        return false  -- WorkDir always shows when no git branch
      end,
      provider = "",
      hl = { fg = "seg_claude", bg = "none" },
    }

    -- Separator between Claude and Git (thin divider)
    local SepClaudeGit = {
      condition = function()
        return has_claude_usage() and has_visible_branch()
      end,
      provider = " │ ",
      hl = { fg = "dim" },
    }

    -- Removed SepGitEnd and SepStartGitNoClaude - no longer needed without bg contrast

    ---------------------------------------------------------------------------
    -- Zoom Indicator Separators (leftmost in right group)
    ---------------------------------------------------------------------------

    local function is_zoomed()
      return vim.g.zoom_win_active
    end

    -- Removed SepStartZoom - no longer needed without bg contrast

    -- Separator after zoom -> claude (thin divider)
    local SepZoomClaude = {
      condition = function()
        return is_zoomed() and has_claude_usage()
      end,
      provider = " │ ",
      hl = { fg = "dim" },
    }

    -- Removed SepStartClaudeNoZoom and SepStartGitNoZoomNoClaude - no longer needed without bg contrast

    -- Separator: Zoom -> Git (thin divider)
    local SepZoomGitNoClaude = {
      condition = function()
        return is_zoomed() and not has_claude_usage() and has_visible_branch()
      end,
      provider = " │ ",
      hl = { fg = "dim" },
    }

    -- Removed SepZoomEndAlone and SepClaudeEndNoGit - no longer needed without bg contrast

    local RightSegments = {
      -- Zoom indicator (leftmost)
      c.ZoomIndicator,
      SepZoomClaude,
      SepZoomGitNoClaude,
      -- Claude usage segments
      c.ClaudeWeekly,
      SepWeeklyPace,
      c.ClaudePace,
      SepPaceBudget,
      c.ClaudeBudget,
      -- Transition from Claude
      SepClaudeGit,
      -- Git branch
      c.GitBranch,
    }

    local TabLine = {
      LeftSegments,
      c.Align,
      RightSegments,
    }

    ---------------------------------------------------------------------------
    -- Empty Statusline (to prevent window separator lines)
    ---------------------------------------------------------------------------

    local EmptyStatusline = {
      provider = "",
    }

    ---------------------------------------------------------------------------
    -- Setup
    ---------------------------------------------------------------------------

    require("heirline").setup({
      statusline = EmptyStatusline,
      tabline = TabLine,
    })
  '';
}
