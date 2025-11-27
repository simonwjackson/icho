{pkgs, ...}: {
  extraPackages = [
    pkgs.bun
  ];

  # Add plugins
  extraPlugins = with pkgs; [
    vimPlugins.supermaven-nvim # AI code completion
    vimPlugins.claudecode-nvim
    vimPlugins.plenary-nvim # Required dependency
    vimPlugins.telescope-nvim # For file selection
  ];

  extraConfigLua = ''
    -- Skip supermaven in headless mode (e.g., nix flake check)
    -- supermaven tries to fetch a binary which fails in the sandbox
    if #vim.api.nvim_list_uis() > 0 then
      local ok, supermaven = pcall(require, "supermaven-nvim")
      if ok then
        supermaven.setup({
          keymaps = {
            accept_suggestion = "<Tab>",
            clear_suggestion = "<C-]>",
            accept_word = "<C-j>",
          },
          ignore_filetypes = { cpp = true }, -- or { "cpp", }
          log_level = "off", -- set to "off" to disable logging completely
          disable_inline_completion = false, -- disables inline completion for use with cmp
          disable_keymaps = false, -- disables built in keymaps for more manual control
          condition = function()
            return false
          end -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
        })

        -- Register supermaven as a cmp source
        local cmp_ok, cmp = pcall(require, "cmp")
        if cmp_ok then
          local config = cmp.get_config()
          table.insert(config.sources, { name = "supermaven" })
          cmp.setup(config)
        end
      end

      -- claudecode.nvim setup (skip in headless mode)
      local claude_ok, claudecode = pcall(require, "claudecode")
      if claude_ok then
        claudecode.setup({
          auto_start = true,
          log_level = "info",
          terminal_cmd = "${pkgs.lib.getExe pkgs.bun} x @anthropic-ai/claude-code --dangerously-skip-permissions",
          terminal = {
            split_side = "right",
            split_width_percentage = 0.40,
            provider = "native",
            auto_close = true,
          },
          diff_opts = {
            auto_close_on_accept = true,
            vertical_split = true,
          },
        })

        -- Auto-reload buffers when files change on disk (for Claude Code edits)
        vim.o.autoread = true

        -- Timer-based file change detection
        local refresh_timer = vim.uv.new_timer()
        refresh_timer:start(0, 1000, vim.schedule_wrap(function()
          if vim.fn.getcmdwintype() == "" then
            vim.cmd("silent! checktime")
          end
        end))

        -- Also check on focus/buffer events
        vim.api.nvim_create_autocmd({"FocusGained", "BufEnter", "CursorHold"}, {
          group = vim.api.nvim_create_augroup("ClaudeCodeAutoReload", { clear = true }),
          callback = function()
            if vim.fn.getcmdwintype() == "" then
              vim.cmd("silent! checktime")
            end
          end,
        })
      end
    end
  '';

  # Add convenient keymaps for Claude AI actions
  keymaps = [
    {
      key = "<leader>ai";
      action = "<cmd>silent! ClaudeCode<CR>";
      options = {
        desc = "Claude Code: Toggle";
      };
    }
    {
      key = "<leader>ac";
      action = "<cmd>silent! ClaudeCode --continue<CR>";
      options = {
        desc = "Claude Code: Continue";
      };
    }
    {
      key = "<leader>ar";
      action = "<cmd>silent! ClaudeCode --resume<CR>";
      options = {
        desc = "Claude Code: Resume";
      };
    }
    {
      key = "<leader>af";
      action = "<cmd>silent! ClaudeCodeAdd %<CR>";
      options = {
        desc = "Claude Code: Send file";
      };
    }
    {
      key = "<leader>av";
      action = "<cmd>silent! ClaudeCodeSend<CR>";
      mode = "v";
      options = {
        desc = "Claude Code: Send selection";
      };
    }
    {
      key = "<leader>aa";
      action = "<cmd>silent! ClaudeCodeDiffAccept<CR>";
      options = {
        desc = "Claude Code: Accept diff";
      };
    }
    {
      key = "<leader>ad";
      action = "<cmd>silent! ClaudeCodeDiffDeny<CR>";
      options = {
        desc = "Claude Code: Deny diff";
      };
    }
    {
      key = "<leader>ae";
      action = "<cmd>lua vim.g.claude_yazi_mode = true; require('yazi').yazi()<CR>";
      options = {
        desc = "Claude Code: Add files (yazi)";
      };
    }
  ];
}
