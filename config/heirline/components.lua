local conditions = require("heirline.conditions")
local utils = require("heirline.utils")
local devicons = require("nvim-web-devicons")

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
    return " " .. self.mode_names[self.mode] .. " "
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
    local bg = utils.get_highlight(hl_group).fg
    return { fg = "bright_bg", bg = bg, bold = true }
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
    return " 🖥️ " .. vim.fn.hostname() .. " "
  end,
  hl = { fg = "bright_fg", bg = "seg_host", bold = true },
}



-- Git Branch
M.GitBranch = {
  condition = conditions.is_git_repo,
  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
  end,
  provider = function(self)
    return " 🌿 " .. self.status_dict.head .. " "
  end,
  hl = { fg = "bright_fg", bg = "seg_git", bold = true },
}





return M
