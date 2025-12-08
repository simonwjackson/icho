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
    local SepHostGit = { provider = "😊", hl = { fg = "seg_host", bg = "seg_git" } }
    local SepHostEnd = { provider = "😊", hl = { fg = "seg_host", bg = "none" } }  -- when no git
    local SepGitEnd = { provider = "😊", hl = { fg = "seg_git", bg = "none" } }

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
      provider = "😊",
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
      provider = "😊",
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
      provider = "😊",
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

    local LeftSegments = {
      c.Hostname,
      {
        condition = conditions.is_git_repo,
        SepHostGit,
        c.GitBranch,
        SepGitEnd,
      },
      {
        condition = function() return not conditions.is_git_repo() end,
        SepHostEnd,
      },
    }

    local RightSegments = {
      SepStartMode,
      c.ViMode,
      SepModeEnd,
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
