local utils = require("heirline.utils")

local M = {}

function M.setup()
  -- Get base colors from colorscheme
  local normal_bg = utils.get_highlight("Normal").bg
  local cursorline_bg = utils.get_highlight("CursorLine").bg
  local visual_bg = utils.get_highlight("Visual").bg
  local pmenu_bg = utils.get_highlight("Pmenu").bg
  local statusline_bg = utils.get_highlight("StatusLine").bg

  return {
    bright_bg = utils.get_highlight("Folded").bg,
    bright_fg = utils.get_highlight("Folded").fg,
    red = utils.get_highlight("DiagnosticError").fg,
    dark_red = utils.get_highlight("DiffDelete").bg,
    green = utils.get_highlight("String").fg,
    blue = utils.get_highlight("Function").fg,
    gray = utils.get_highlight("NonText").fg,
    dim = utils.get_highlight("LineNr").fg,
    orange = utils.get_highlight("Constant").fg,
    purple = utils.get_highlight("Statement").fg,
    cyan = utils.get_highlight("Special").fg,
    diag_warn = utils.get_highlight("DiagnosticWarn").fg,
    diag_error = utils.get_highlight("DiagnosticError").fg,
    diag_hint = utils.get_highlight("DiagnosticHint").fg,
    diag_info = utils.get_highlight("DiagnosticInfo").fg,
    git_del = utils.get_highlight("diffRemoved").fg or utils.get_highlight("DiagnosticError").fg,
    git_add = utils.get_highlight("diffAdded").fg or utils.get_highlight("String").fg,
    git_change = utils.get_highlight("diffChanged").fg or utils.get_highlight("Function").fg,
    tabline_bg = utils.get_highlight("TabLineFill").bg or "none",
    tabline_fg = utils.get_highlight("TabLine").fg,
    -- Segment colors - all use same dim background
    seg_host = cursorline_bg,
    seg_dir = cursorline_bg,
    seg_git = cursorline_bg,
    seg_time = cursorline_bg,
    seg_mode = cursorline_bg,
    seg_file = cursorline_bg,
    seg_diag = cursorline_bg,
    seg_lsp = cursorline_bg,
    seg_pos = cursorline_bg,
    -- Claude usage segment colors
    seg_claude = cursorline_bg,
    claude_warning = utils.get_highlight("DiagnosticWarn").fg,
    claude_danger = utils.get_highlight("DiagnosticError").fg,
  }
end

return M
