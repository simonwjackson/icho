local conditions = require("heirline.conditions")
local utils = require("heirline.utils")
local devicons = require("nvim-web-devicons")
local claude = require("heirline.claude_usage")

local M = {}

-- Basic components
M.Align = { provider = "%=" }
M.Space = { provider = " " }

-- Vi Mode
M.ViMode = {
  init = function(self)
    self.mode = vim.fn.mode(1)
  end,
  static = {
    mode_names = {
      n = "N", no = "N?", nov = "N?", noV = "N?", ["no\22"] = "N?",
      niI = "Ni", niR = "Nr", niV = "Nv", nt = "Nt",
      v = "V", vs = "Vs", V = "V_", Vs = "Vs", ["\22"] = "^V", ["\22s"] = "^V",
      s = "S", S = "S_", ["\19"] = "^S",
      i = "I", ic = "Ic", ix = "Ix",
      R = "R", Rc = "Rc", Rx = "Rx", Rv = "Rv", Rvc = "Rv", Rvx = "Rv",
      c = "C", cv = "Ex", r = "...", rm = "M", ["r?"] = "?", ["!"] = "!", t = "T",
    },
  },
  provider = function(self)
    return self.mode_names[self.mode]
  end,
  hl = function(self)
    local mode = self.mode:sub(1, 1)
    -- Use colorscheme highlights for mode colors
    local mode_hl = {
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
    local hl_group = mode_hl[mode] or "Function"
    local fg = utils.get_highlight(hl_group).fg
    return { fg = fg, bold = true }
  end,
  update = {
    "ModeChanged",
    pattern = "*:*",
    callback = vim.schedule_wrap(function()
      vim.cmd("redrawtabline")
    end),
  },
}





-- Hostname
M.Hostname = {
  provider = function()
    return " 󰒋  " .. vim.fn.hostname() .. ""
  end,
  hl = { fg = "blue", bold = true },
}



-- Git Branch (shows any branch when in a git repo) - RIGHT SIDE
M.GitBranch = {
  condition = function(self)
    local handle = io.popen("git branch --show-current 2>/dev/null")
    if handle then
      self.branch = handle:read("*a"):gsub("^%s*(.-)%s*$", "%1")
      handle:close()
    else
      self.branch = ""
    end

    -- Show if we have a branch (any branch)
    return self.branch ~= ""
  end,
  provider = function(self)
    return "󰘬  " .. self.branch .. " "
  end,
  hl = { fg = "purple", bold = true },
}

-- WorkDir (shows folder name) - LEFT SIDE, always shows
M.WorkDir = {
  provider = function()
    local cwd = vim.fn.getcwd()
    local folder = vim.fn.fnamemodify(cwd, ":t")
    return "  " .. folder .. ""
  end,
  hl = { fg = "cyan", bold = true },
}

-- ============================================================================
-- Claude Usage Segments
-- ============================================================================

-- Helper to check if claude usage data is available
local function has_claude_usage(self)
  local data = claude.get_usage_data()
  if not data or not data.seven_day then return false end
  self.seven_day = data.seven_day
  return true
end

-- Weekly usage segment: shows current 7-day utilization %
-- Colors based on projected end-of-week usage
M.ClaudeWeekly = {
  condition = has_claude_usage,
  provider = function(self)
    local pct = math.floor(self.seven_day.utilization)
    return " 󰃭  " .. pct .. "% "
  end,
  hl = function(self)
    local severity = claude.get_weekly_severity(
      self.seven_day.utilization,
      self.seven_day.resets_at
    )
    if severity == "danger" then
      return { fg = "claude_danger", bold = true }
    elseif severity == "warning" then
      return { fg = "claude_warning", bold = true }
    end
    return { fg = "gray", bold = true }
  end,
  update = { "User", pattern = "ClaudeUsageUpdated" },
}

-- Pace segment: shows how far ahead/behind expected schedule
-- Positive = under budget (good), Negative = over budget (bad)
M.ClaudePace = {
  condition = has_claude_usage,
  provider = function(self)
    local pace = claude.calculate_pace(
      self.seven_day.utilization,
      self.seven_day.resets_at
    )
    local sign = pace >= 0 and "+" or ""
    return "󰓅  " .. sign .. string.format("%.1f", pace) .. "% "
  end,
  hl = function(self)
    local pace = claude.calculate_pace(
      self.seven_day.utilization,
      self.seven_day.resets_at
    )
    local severity = claude.get_pace_severity(pace)
    if severity == "danger" then
      return { fg = "claude_danger", bold = true }
    elseif severity == "warning" then
      return { fg = "claude_warning", bold = true }
    end
    return { fg = "gray", bold = true }
  end,
  update = { "User", pattern = "ClaudeUsageUpdated" },
}

-- Budget segment: shows % available per remaining work day
M.ClaudeBudget = {
  condition = has_claude_usage,
  provider = function(self)
    local budget = claude.calculate_daily_budget(
      self.seven_day.utilization,
      self.seven_day.resets_at
    )
    return "󰀻  " .. string.format("%.1f", budget) .. "% "
  end,
  hl = { fg = "gray", bold = true },
  update = { "User", pattern = "ClaudeUsageUpdated" },
}


-- Zoom indicator
M.ZoomIndicator = {
  condition = function()
    return vim.g.zoom_win_active
  end,
  provider = " 󰊓  ",
  hl = { fg = "orange", bold = true },
}

return M
