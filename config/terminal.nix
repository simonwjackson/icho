{
  keymaps = [
    { key = "<A-h>"; action = "<Cmd>wincmd h<CR>"; options.desc = "Window left"; }
    { key = "<A-j>"; action = "<Cmd>wincmd j<CR>"; options.desc = "Window down"; }
    { key = "<A-k>"; action = "<Cmd>wincmd k<CR>"; options.desc = "Window up"; }
    { key = "<A-l>"; action = "<Cmd>wincmd l<CR>"; options.desc = "Window right"; }
  ];

  extraConfigLua = ''
    -- Darken helper function
    local function darken(hex, factor)
      factor = factor or 0.85
      hex = hex:gsub("#", "")
      local r = math.floor(tonumber(hex:sub(1, 2), 16) * factor)
      local g = math.floor(tonumber(hex:sub(3, 4), 16) * factor)
      local b = math.floor(tonumber(hex:sub(5, 6), 16) * factor)
      return string.format("#%02x%02x%02x", r, g, b)
    end

    -- Set terminal background to match tabline (darker)
    local function set_terminal_bg()
      local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
      if normal_bg then
        local darker_bg = darken(string.format("#%06x", normal_bg), 0.85)
        vim.api.nvim_set_hl(0, "TerminalBg", { bg = darker_bg })
      end
    end

    set_terminal_bg()

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_terminal_bg,
      group = vim.api.nvim_create_augroup("TerminalBg", { clear = true }),
    })

    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set("t", "<A-Esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "<A-h>", [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set("t", "<A-j>", [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set("t", "<A-k>", [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set("t", "<A-l>", [[<Cmd>wincmd l<CR>]], opts)

      -- Apply darker background to terminal
      vim.wo.winhighlight = "Normal:TerminalBg"
    end

    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

    ---------------------------------------------------------------------------
    -- Popup Terminal Apps (persistent tmux sessions)
    ---------------------------------------------------------------------------

    local popup_apps = {}  -- Track popup state per app

    -- Create dim overlay highlight
    vim.api.nvim_set_hl(0, "PopupDim", { bg = "#000000", blend = 20 })

    local function create_dim_overlay()
      local dim_buf = vim.api.nvim_create_buf(false, true)
      local dim_win = vim.api.nvim_open_win(dim_buf, false, {
        relative = "editor",
        row = 0,
        col = 0,
        width = vim.o.columns,
        height = vim.o.lines,
        style = "minimal",
        zindex = 40,
      })
      vim.wo[dim_win].winhighlight = "Normal:PopupDim"
      vim.wo[dim_win].winblend = 20
      return dim_win, dim_buf
    end

    local function toggle_popup_app(name, cmd)
      local app = popup_apps[name]

      -- If popup is open, close it
      if app and app.win and vim.api.nvim_win_is_valid(app.win) then
        vim.api.nvim_win_close(app.win, true)
        if app.dim_win and vim.api.nvim_win_is_valid(app.dim_win) then
          vim.api.nvim_win_close(app.dim_win, true)
        end
        app.win = nil
        app.dim_win = nil
        return
      end

      -- Create or reuse terminal buffer
      if not app then
        popup_apps[name] = { buf = nil, win = nil, dim_win = nil, dim_buf = nil }
        app = popup_apps[name]
      end

      -- Create dim overlay
      app.dim_win, app.dim_buf = create_dim_overlay()

      -- Calculate 80% centered window
      local width = math.floor(vim.o.columns * 0.8)
      local height = math.floor(vim.o.lines * 0.8)
      local row = math.floor((vim.o.lines - height) / 2)
      local col = math.floor((vim.o.columns - width) / 2)

      -- Create or reuse terminal buffer
      if not app.buf or not vim.api.nvim_buf_is_valid(app.buf) then
        app.buf = vim.api.nvim_create_buf(false, true)
        -- tmux command: attach to existing session or create new one with the app
        local tmux_cmd = string.format(
          "/run/current-system/sw/bin/nix shell nixpkgs#tmux -c tmux new-session -A -s '%s' '%s'",
          name,
          cmd
        )
        vim.api.nvim_buf_call(app.buf, function()
          vim.fn.termopen(tmux_cmd, {
            on_exit = function()
              -- Clean up on exit
              if app.win and vim.api.nvim_win_is_valid(app.win) then
                vim.api.nvim_win_close(app.win, true)
              end
              if app.dim_win and vim.api.nvim_win_is_valid(app.dim_win) then
                vim.api.nvim_win_close(app.dim_win, true)
              end
              app.buf = nil
              app.win = nil
              app.dim_win = nil
            end,
          })
        end)
      end

      -- Open floating window
      app.win = vim.api.nvim_open_win(app.buf, true, {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        zindex = 50,
      })

      -- Enter terminal mode
      vim.cmd("startinsert")

      -- Set up keymaps to close popup
      local close_keys = { "<A-Esc>", "q" }
      for _, key in ipairs(close_keys) do
        vim.keymap.set("t", key, function()
          -- Detach from tmux first (Ctrl-b d)
          local chan = vim.bo[app.buf].channel
          if chan and chan > 0 then
            vim.api.nvim_chan_send(chan, "\x02d")  -- Ctrl-b d to detach
          end
          vim.defer_fn(function()
            if app.win and vim.api.nvim_win_is_valid(app.win) then
              vim.api.nvim_win_close(app.win, true)
            end
            if app.dim_win and vim.api.nvim_win_is_valid(app.dim_win) then
              vim.api.nvim_win_close(app.dim_win, true)
            end
            app.win = nil
            app.dim_win = nil
          end, 50)
        end, { buffer = app.buf, desc = "Close " .. name })
      end
    end

    -- Popup app keybindings
    vim.keymap.set("n", "<leader>rb", function()
      toggle_popup_app("btop", "/run/current-system/sw/bin/nix run nixpkgs#btop")
    end, { desc = "Popup: btop" })
  '';
}
