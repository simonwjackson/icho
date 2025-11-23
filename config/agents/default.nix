{pkgs, ...}: {
  extraPackages = [
    # pkgs.claude-code
    pkgs.bun
  ];

  # Add plugins
  extraPlugins = with pkgs; [
    vimPlugins.supermaven-nvim # AI code completion
    vimPlugins.claude-code-nvim
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
    end

    require("claude-code").setup({
        window = {
          -- split_ratio = 0.381,
          position = 'vertical', -- Test the new "none" position option
          enter_insert = true,
          hide_numbers = true,
          hide_signcolumn = true,
        },
        refresh = {
          enable = true,
          updatetime = 100,
          timer_interval = 1000,
          show_notifications = true,
        },
        git = {
          use_git_root = true,
        },
        command = "${pkgs.lib.getExe pkgs.bun} x '@anthropic-ai/claude-code' --dangerously-skip-permissions",
        -- keymaps = {
        --   window_navigation = false,
        -- },
    })

    ${builtins.readFile ./agent-commands.lua}
  '';

  # Add convenient keymaps for Claude AI actions
  keymaps = [
    # Chats
    {
      key = "<leader>ai";
      action = "<cmd>ClaudeCodeInput<CR>";
      options = {
        desc = "Claude Code: Toggle Input Buffer";
      };
    }

    # Context: Selection
    {
      mode = "n";
      key = "<leader>av";
      action = "<cmd>ClaudeCodeSelection<CR>";
      options = {
        desc = "Send current line to Claude Code";
      };
    }
    {
      mode = "v";
      key = "<leader>av";
      action = ":<C-u>ClaudeCodeSelection<CR>";
      options = {
        desc = "Send visual selection to Claude Code";
      };
    }
    {
      mode = "x";
      key = "<leader>av";
      action = ":<C-u>ClaudeCodeSelection<CR>";
      options = {
        desc = "Send visual selection to Claude Code";
      };
    }

    # Context: Paths
    {
      key = "<leader>aff";
      action = "<cmd>ClaudeCodeFile<CR>";
      options = {
        desc = "Claude Code: File (add)";
      };
    }
    {
      key = "<leader>afe";
      action = "<cmd>ClaudeCodeFiles<CR>";
      options = {
        desc = "Claude Code: Files (multi add)";
      };
    }
    {
      key = "<leader>afw";
      action = "<cmd>ClaudeCodeFilesWithContent<CR>";
      options = {
        desc = "Claude Code: Files by content search";
      };
    }
    {
      key = "<leader>afd";
      action = "<cmd>ClaudeCodeDirectories<CR>";
      options = {
        desc = "Claude Code: Directories";
      };
    }

    {
      key = "<leader>ap";
      action = "<cmd>ClaudeCodePrompt<CR>";
      options = {
        desc = "Claude Code: Prompts";
      };
    }
    {
      key = "<leader>aP";
      action = "<cmd>Explore ~/.claude/commands<CR>";
      options = {
        desc = "Open netrw to prompt directory";
      };
    }
  ];
}
