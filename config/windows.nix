{ pkgs, ... }: {
  # Required vim options for animations
  opts = {
    winwidth = 10;
    winminwidth = 10;
    equalalways = false;
  };

  extraPlugins = with pkgs.vimPlugins; [
    middleclass
    animation-nvim
    windows-nvim
  ];

  extraConfigLua = ''
    vim.o.winwidth = 10
    vim.o.winminwidth = 10
    vim.o.equalalways = false

    -- Don't use windows.nvim autowidth - implement our own golden ratio that respects fixed sidebars
    require('windows').setup({
      autowidth = {
        enable = false,
      },
      ignore = {
        filetype = { "NvimTree", "neo-tree", "undotree", "gundo", "yazi", "snacks_terminal", "lazygit", "opencode", "opencode_terminal" },
        buftype = { "quickfix", "terminal" }
      },
      animation = {
        enable = true,
        duration = 150,
        fps = 60,
        easing = "in_out_sine"
      }
    })

    -- Custom golden ratio implementation that excludes fixed sidebars
    local ignored_filetypes = {
      opencode = true,
      opencode_terminal = true,
      NvimTree = true,
      ["neo-tree"] = true,
      undotree = true,
      gundo = true,
      yazi = true,
      snacks_terminal = true,
      lazygit = true,
    }

    local ignored_buftypes = {
      quickfix = true,
      terminal = true,
    }

    local function is_ignored(win)
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      local bt = vim.bo[buf].buftype
      return ignored_filetypes[ft] or ignored_buftypes[bt]
    end

    local function get_resizable_wins()
      local wins = {}
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local cfg = vim.api.nvim_win_get_config(win)
        if cfg.relative == "" and not is_ignored(win) then
          table.insert(wins, win)
        end
      end
      return wins
    end

    local function get_ignored_width()
      local total = 0
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local cfg = vim.api.nvim_win_get_config(win)
        if cfg.relative == "" and is_ignored(win) then
          total = total + vim.api.nvim_win_get_width(win) + 1  -- +1 for separator
        end
      end
      return total
    end

    local function apply_golden_ratio()
      local wins = get_resizable_wins()
      if #wins < 2 then return end

      local cur_win = vim.api.nvim_get_current_win()
      if is_ignored(cur_win) then return end

      local ignored_width = get_ignored_width()
      local available = vim.o.columns - ignored_width
      local separators = #wins - 1

      local focused_width = math.floor((available - separators) * 0.618)
      local remaining = available - separators - focused_width
      local other_width = math.floor(remaining / (#wins - 1))

      for _, win in ipairs(wins) do
        if win == cur_win then
          vim.api.nvim_win_set_width(win, focused_width)
        else
          vim.api.nvim_win_set_width(win, other_width)
        end
      end
    end

    vim.api.nvim_create_autocmd("WinEnter", {
      callback = function()
        vim.defer_fn(apply_golden_ratio, 10)
      end,
    })
  '';
}
