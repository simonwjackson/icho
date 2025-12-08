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

    -- Track zoom state
    local zoom_win = nil
    vim.keymap.set("n", "<A-m>", function()
      -- If zoomed, close the zoom window
      if zoom_win then
        pcall(function() zoom_win:close() end)
        zoom_win = nil
        return
      end
      -- Otherwise, zoom current buffer
      zoom_win = Snacks.zen.zoom()
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
