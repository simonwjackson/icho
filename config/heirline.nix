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
    local SepHostGit = { provider = "", hl = { fg = "seg_host", bg = "seg_git" } }
    local SepHostEnd = { provider = "", hl = { fg = "seg_host", bg = "none" } }  -- when no git
    local SepGitEnd = { provider = "", hl = { fg = "seg_git", bg = "none" } }

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

    -- Separator: Host -> WorkDir
    local SepHostDir = {
      provider = "",
      hl = { fg = "seg_host", bg = "seg_dir" },
    }

    -- Separator: WorkDir -> Mode
    local SepDirMode = {
      init = function(self)
        self.mode = vim.fn.mode(1)
      end,
      provider = "",
      hl = function(self)
        local mode = self.mode:sub(1, 1)
        local hl_group = mode_hl_map[mode] or "Function"
        local bg = utils.get_highlight(hl_group).fg
        return { fg = "seg_dir", bg = bg }
      end,
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
      SepModeEnd,
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

    -- Separator between Weekly and Pace
    local SepWeeklyPace = {
      condition = has_claude_usage,
      provider = "",
      hl = function()
        local data = claude_usage.get_usage_data()
        if data and data.seven_day then
          local weekly_severity = claude_usage.get_weekly_severity(
            data.seven_day.utilization,
            data.seven_day.resets_at
          )
          local pace = claude_usage.calculate_pace(
            data.seven_day.utilization,
            data.seven_day.resets_at
          )
          local pace_severity = claude_usage.get_pace_severity(pace)

          local fg_color = weekly_severity == "danger" and "claude_danger"
            or weekly_severity == "warning" and "claude_warning"
            or "seg_claude"
          local bg_color = pace_severity == "danger" and "claude_danger"
            or pace_severity == "warning" and "claude_warning"
            or "seg_claude"

          return { fg = fg_color, bg = bg_color }
        end
        return { fg = "seg_claude", bg = "seg_claude" }
      end,
    }

    -- Separator between Pace and Budget
    local SepPaceBudget = {
      condition = has_claude_usage,
      provider = "",
      hl = function()
        local data = claude_usage.get_usage_data()
        if data and data.seven_day then
          local pace = claude_usage.calculate_pace(
            data.seven_day.utilization,
            data.seven_day.resets_at
          )
          local pace_severity = claude_usage.get_pace_severity(pace)

          local fg_color = pace_severity == "danger" and "claude_danger"
            or pace_severity == "warning" and "claude_warning"
            or "seg_claude"

          return { fg = fg_color, bg = "seg_claude" }
        end
        return { fg = "seg_claude", bg = "seg_claude" }
      end,
    }

    -- End separator after Budget - never used now since WorkDir always follows when no git
    local SepClaudeEnd = {
      condition = function()
        return false  -- WorkDir always shows when no git branch
      end,
      provider = "",
      hl = { fg = "seg_claude", bg = "none" },
    }

    -- Separator between Claude and Git (when both visible)
    local SepClaudeGit = {
      condition = function()
        return has_claude_usage() and has_visible_branch()
      end,
      provider = "",
      hl = { fg = "seg_claude", bg = "seg_git" },
    }

    -- End separator after Git (when zoom NOT active)
    local SepGitEnd = {
      condition = function()
        return has_visible_branch() and not vim.g.zoom_win_active
      end,
      provider = "",
      hl = { fg = "seg_git", bg = "none" },
    }

    -- Git start separator only when Claude is NOT visible
    local SepStartGitNoClaude = {
      condition = function()
        return has_visible_branch() and not has_claude_usage()
      end,
      provider = "",
      hl = { fg = "seg_git", bg = "none" },
    }

    ---------------------------------------------------------------------------
    -- Zoom Indicator Separators (leftmost in right group)
    ---------------------------------------------------------------------------

    local function is_zoomed()
      return vim.g.zoom_win_active
    end

    -- Start separator for zoom (leftmost)
    local SepStartZoom = {
      condition = is_zoomed,
      provider = "",
      hl = { fg = "seg_host", bg = "none" },
    }

    -- Separator after zoom -> claude
    local SepZoomClaude = {
      condition = function()
        return is_zoomed() and has_claude_usage()
      end,
      provider = "",
      hl = function()
        local data = claude_usage.get_usage_data()
        if data and data.seven_day then
          local severity = claude_usage.get_weekly_severity(
            data.seven_day.utilization,
            data.seven_day.resets_at
          )
          if severity == "danger" then
            return { fg = "seg_host", bg = "claude_danger" }
          elseif severity == "warning" then
            return { fg = "seg_host", bg = "claude_warning" }
          end
        end
        return { fg = "seg_host", bg = "seg_claude" }
      end,
    }

    -- Modified: Claude start only when NOT zoomed
    local SepStartClaudeNoZoom = {
      condition = function()
        return has_claude_usage() and not is_zoomed()
      end,
      provider = "",
      hl = function()
        local data = claude_usage.get_usage_data()
        if data and data.seven_day then
          local severity = claude_usage.get_weekly_severity(
            data.seven_day.utilization,
            data.seven_day.resets_at
          )
          if severity == "danger" then
            return { fg = "claude_danger", bg = "none" }
          elseif severity == "warning" then
            return { fg = "claude_warning", bg = "none" }
          end
        end
        return { fg = "seg_claude", bg = "none" }
      end,
    }

    -- Modified: Git start only when NOT zoomed and no claude
    local SepStartGitNoZoomNoClaude = {
      condition = function()
        return has_visible_branch() and not has_claude_usage() and not is_zoomed()
      end,
      provider = "",
      hl = { fg = "seg_git", bg = "none" },
    }

    -- Separator: Zoom -> Git (no claude, has git)
    local SepZoomGitNoClaude = {
      condition = function()
        return is_zoomed() and not has_claude_usage() and has_visible_branch()
      end,
      provider = "",
      hl = { fg = "seg_host", bg = "seg_git" },
    }

    -- End separator after Zoom (no claude, no git)
    local SepZoomEndAlone = {
      condition = function()
        return is_zoomed() and not has_claude_usage() and not has_visible_branch()
      end,
      provider = "",
      hl = { fg = "seg_host", bg = "none" },
    }

    -- Claude end (no git after)
    local SepClaudeEndNoGit = {
      condition = function()
        return has_claude_usage() and not has_visible_branch()
      end,
      provider = "",
      hl = { fg = "seg_claude", bg = "none" },
    }

    local RightSegments = {
      -- Zoom indicator (leftmost)
      SepStartZoom,
      c.ZoomIndicator,
      SepZoomClaude,
      SepZoomGitNoClaude,
      SepZoomEndAlone,
      -- Claude usage segments
      SepStartClaudeNoZoom,
      c.ClaudeWeekly,
      SepWeeklyPace,
      c.ClaudePace,
      SepPaceBudget,
      c.ClaudeBudget,
      -- Transition from Claude
      SepClaudeGit,
      SepClaudeEndNoGit,
      -- Git branch
      SepStartGitNoZoomNoClaude,
      c.GitBranch,
      SepGitEnd,
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
