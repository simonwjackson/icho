{pkgs, ...}: 
let
  opencode-wrapper = pkgs.writeShellScriptBin "opencode" ''
    exec ${pkgs.steam-run}/bin/steam-run ${pkgs.bun}/bin/bun x opencode-ai@latest "$@"
  '';
in
{
  extraPlugins = [
    pkgs.vimPlugins.opencode-nvim
  ];

  extraPackages = [
    opencode-wrapper
    pkgs.lsof
  ];

  opts.autoread = true;

  extraConfigLua = ''
    vim.g.opencode_opts = {
      provider = {
        enabled = "snacks",
        snacks = {
          cmd = { "opencode" },
        },
      },
    }

    -- Keymaps (<leader>a prefix for opencode)
    vim.keymap.set({ "n", "x" }, "<leader>aa", function() require("opencode").ask("\n@this: ") end, { desc = "Ask opencode" })
    vim.keymap.set({ "n", "x" }, "<leader>as", function() require("opencode").select() end, { desc = "Select opencode action" })
    vim.keymap.set({ "n", "x" }, "<leader>ap", function() require("opencode").prompt("\n@this") end, { desc = "Prompt with context" })
    vim.keymap.set("n", "<leader>at", function() require("opencode").toggle() end, { desc = "Toggle opencode" })
    vim.keymap.set({ "n", "x" }, "<leader>ai", function() require("opencode").ask("\n") end, { desc = "Input prompt" })
    -- Helper to focus opencode window and enter terminal mode
    local function focus_opencode(enter_terminal_mode)
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].filetype == "opencode_terminal" then
          local wins = vim.fn.win_findbuf(buf)
          if #wins > 0 then
            vim.api.nvim_set_current_win(wins[1])
            if enter_terminal_mode ~= false then
              vim.cmd("startinsert")
            end
            return true
          end
        end
      end
      return false
    end

    vim.keymap.set("n", "<leader>ag", function()
      if not focus_opencode() then
        require("opencode").toggle()
      end
    end, { desc = "Go to opencode" })

    -- Zoom toggle: custom floating window below tabline
    local zoom_win = nil
    local zoom_buf = nil
    vim.keymap.set("n", "<A-m>", function()
      if zoom_win and vim.api.nvim_win_is_valid(zoom_win) then
        -- Unzoom: close float, go back to original window
        local cursor = vim.api.nvim_win_get_cursor(zoom_win)
        local buf = zoom_buf
        vim.api.nvim_win_close(zoom_win, false)
        -- Restore cursor in original window showing same buffer
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_buf(win) == buf then
            vim.api.nvim_set_current_win(win)
            pcall(vim.api.nvim_win_set_cursor, win, cursor)
            break
          end
        end
        zoom_win = nil
        zoom_buf = nil
        vim.g.zoom_win_active = false
        -- Enter insert mode if it's a terminal
        if vim.bo[buf].buftype == "terminal" then
          vim.cmd("startinsert")
        end
      else
        -- Zoom: create floating window covering entire editor
        zoom_buf = vim.api.nvim_get_current_buf()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local width = vim.o.columns
        local height = vim.o.lines - vim.o.cmdheight - 1  -- only leave cmdline
        zoom_win = vim.api.nvim_open_win(zoom_buf, true, {
          relative = "editor",
          row = 0,  -- start at top, covering tabline
          col = 0,
          width = width,
          height = height,
          style = "minimal",
          border = "none",
          zindex = 50,
        })
        -- Use Normal background instead of NormalFloat
        vim.wo[zoom_win].winhighlight = "NormalFloat:Normal"
        vim.api.nvim_win_set_cursor(zoom_win, cursor)
        vim.g.zoom_win_active = true
        -- Enter insert mode if it's a terminal
        if vim.bo[zoom_buf].buftype == "terminal" then
          vim.cmd("startinsert")
        end
      end
      vim.cmd("redrawtabline")
    end, { desc = "Toggle zoom" })

    -- Helper to send keys to opencode terminal
    local function send_to_opencode(keys)
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].filetype == "opencode_terminal" then
          local chan = vim.bo[buf].channel
          if chan and chan > 0 then
            vim.api.nvim_chan_send(chan, keys)
          end
          return true
        end
      end
      return false
    end

    -- Session commands
    vim.keymap.set("n", "<leader>an", function() require("opencode").command("session.new") end, { desc = "New session" })
    vim.keymap.set("n", "<leader>al", function()
      require("opencode").command("session.list")
      vim.defer_fn(focus_opencode, 100)
    end, { desc = "List sessions" })
    vim.keymap.set("n", "<leader>ah", function()
      -- Note: session.timeline only works when viewing a session in opencode
      require("opencode").command("session.timeline")
      vim.defer_fn(focus_opencode, 100)
    end, { desc = "Timeline (in session)" })
    vim.keymap.set("n", "<leader>ac", function() require("opencode").command("session.compact") end, { desc = "Compact session" })
    vim.keymap.set("n", "<leader>ax", function() require("opencode").command("session.interrupt") end, { desc = "Interrupt session" })
    vim.keymap.set("n", "<leader>au", function() require("opencode").command("session.undo") end, { desc = "Undo" })
    vim.keymap.set("n", "<leader>ar", function() require("opencode").command("session.redo") end, { desc = "Redo" })

    -- Built-in prompts (with newline prefix to separate from previous input)
    vim.keymap.set({ "n", "x" }, "<leader>ae", function() require("opencode").prompt("\nExplain @this and its context") end, { desc = "Explain" })
    vim.keymap.set({ "n", "x" }, "<leader>ao", function() require("opencode").prompt("\nOptimize @this for performance and readability") end, { desc = "Optimize" })
    vim.keymap.set({ "n", "x" }, "<leader>av", function() require("opencode").prompt("\nReview @this for correctness and readability") end, { desc = "Review" })
    vim.keymap.set({ "n", "x" }, "<leader>ad", function() require("opencode").prompt("\nAdd comments documenting @this") end, { desc = "Document" })
    vim.keymap.set({ "n", "x" }, "<leader>af", function() require("opencode").prompt("\nFix @diagnostics") end, { desc = "Fix diagnostics" })
    vim.keymap.set("n", "<leader>aD", function() require("opencode").prompt("\nReview the following git diff for correctness and readability: @diff") end, { desc = "Review diff" })
  '';
}
