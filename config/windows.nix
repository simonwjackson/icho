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
        filetype = { "NvimTree", "neo-tree", "undotree", "gundo", "yazi", "snacks_terminal", "lazygit", "opencode", "opencode_terminal", "OverseerList", "grug-far" },
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
      OverseerList = true,
      ["grug-far"] = true,
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

    -- Animation state
    local animation_fps = 60
    local animation_duration = 150  -- ms
    local animation_timer = nil

    local function ease_in_out_sine(t)
      return -(math.cos(math.pi * t) - 1) / 2
    end

    local function animate_windows(target_widths)
      if animation_timer then
        animation_timer:stop()
        animation_timer = nil
      end

      -- Get current widths
      local start_widths = {}
      for win, _ in pairs(target_widths) do
        if vim.api.nvim_win_is_valid(win) then
          start_widths[win] = vim.api.nvim_win_get_width(win)
        end
      end

      local frame_time = 1000 / animation_fps
      local total_frames = math.floor(animation_duration / frame_time)
      local current_frame = 0

      animation_timer = vim.uv.new_timer()
      animation_timer:start(0, frame_time, vim.schedule_wrap(function()
        current_frame = current_frame + 1
        local progress = ease_in_out_sine(current_frame / total_frames)

        for win, target in pairs(target_widths) do
          if vim.api.nvim_win_is_valid(win) then
            local start = start_widths[win] or target
            local current = math.floor(start + (target - start) * progress)
            pcall(vim.api.nvim_win_set_width, win, current)
          end
        end

        if current_frame >= total_frames then
          animation_timer:stop()
          animation_timer = nil
          -- Ensure final widths are exact
          for win, target in pairs(target_widths) do
            if vim.api.nvim_win_is_valid(win) then
              pcall(vim.api.nvim_win_set_width, win, target)
            end
          end
        end
      end))
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

      local target_widths = {}
      for _, win in ipairs(wins) do
        if win == cur_win then
          target_widths[win] = focused_width
        else
          target_widths[win] = other_width
        end
      end

      animate_windows(target_widths)
    end

    vim.api.nvim_create_autocmd("WinEnter", {
      callback = function()
        vim.defer_fn(apply_golden_ratio, 10)
      end,
    })
  '';
}
