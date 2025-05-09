{pkgs, ...}: {
  extraPackages = [
    pkgs.claude-code
    # pkgs.nodejs_latest
  ];

  # Create plugin from GitHub source
  extraPlugins = with pkgs; [
    vimPlugins.supermaven-nvim # AI code completion
    (vimUtils.buildVimPlugin {
      name = "claude-code-nvim";
      src = fetchFromGitHub {
        owner = "greggh";
        repo = "claude-code.nvim";
        rev = "main";
        sha256 = "sha256-4H6zu5+iDPnCY+ISsxuL9gtAZ5lJhVvtOscc8jUsAY8=";
      };
    })
    vimPlugins.plenary-nvim # Required dependency
    vimPlugins.telescope-nvim # For file selection
  ];

  extraConfigLua = ''
    -- Workaround for supermaven initialization issues
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
    end

    require("claude-code").setup({
      window = {
        split_ratio = 0.381,
        position = "vsplit", -- Changed from "vertical" to "vsplit"
      },
      command = "${pkgs.claude-code}/bin/claude --dangerously-skip-permissions",
      -- command = "~/.claude/local/claude --dangerously-skip-permissions",
      command_variants = {
        -- Conversation management
        continue = "--continue", -- Resume the most recent conversation
        resume = "--resume",     -- Display an interactive conversation picker

        -- Output options
        verbose = "--verbose",   -- Enable verbose logging with full turn-by-turn output
        commit = "'execute a commitizen style commit for everything staged. if no files are staged, then commit all. Do not use any claude branding.'",
      },
      keymaps = {
        window_navigation = false,
      },
      -- terminal_opts = {
      --   unique_name = true,
      --   force_unique = true, -- Force a unique name even if a buffer with the same name exists
      --   close_on_exit = true  -- Close the terminal buffer when the job exits
      -- }
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
      key = "<leader>av";
      action = "<cmd>ClaudeCodeSelection<CR>";
      options = {
        desc = "Claude Code: Selection (add)";
      };
    }
    {
      key = "<leader>ag";
      action = "<cmd>ClaudeCodeSend<CR>";
      options = {
        desc = "Claude Code: Send agent-input";
      };
    }

    # Context: Paths
    {
      key = "<leader>af";
      action = "<cmd>ClaudeCodeFile<CR>";
      options = {
        desc = "Claude Code: File (add)";
      };
    }
    {
      key = "<leader>aF";
      action = "<cmd>ClaudeCodeFiles<CR>";
      options = {
        desc = "Claude Code: Files (multi add)";
      };
    }
    {
      key = "<leader>ad";
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

    # Misc
    {
      key = "<leader>aG";
      action = "<cmd>ClaudeCodeCommit<CR>";
      options = {
        desc = "Claude Code: Git Commit";
      };
    }
  ];
}
