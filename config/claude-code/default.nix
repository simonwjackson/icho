{pkgs, ...}: {
  extraPackages = [
    # pkgs.claude-code
  ];

  # Create plugin from GitHub source
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "claude-code-nvim";
      src = pkgs.fetchFromGitHub {
        owner = "greggh";
        repo = "claude-code.nvim";
        rev = "main";
        sha256 = "sha256-4H6zu5+iDPnCY+ISsxuL9gtAZ5lJhVvtOscc8jUsAY8=";
      };
    })
    pkgs.vimPlugins.plenary-nvim # Required dependency
    pkgs.vimPlugins.telescope-nvim # For file selection
  ];

  # Configure the plugin
  extraConfigLua = ''
    require("claude-code").setup({
      window = {
        split_ratio = 0.381,
        position = "vsplit", -- Changed from "vertical" to "vsplit"
      },
      command = "${pkgs.claude-code}/bin/claude --dangerously-skip-permissions",
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

    ${builtins.readFile ./lua/file_command.lua}
    ${builtins.readFile ./lua/selection_command.lua}
    ${builtins.readFile ./lua/files_command.lua}
    ${builtins.readFile ./lua/directories_command.lua}
  '';

  # Add convenient keymaps for Claude AI actions
  keymaps = [
    # Chats
    {
      key = "<leader>ac";
      action = "<cmd>ClaudeCode<CR>";
      options = {
        desc = "Claude Code: Toggle";
      };
    }
    {
      key = "<leader>aC";
      action = "<cmd>ClaudeCodeContinue<CR>";
      options = {
        desc = "Claude Code: History";
      };
    }
    {
      key = "<leader>ah";
      action = "<cmd>ClaudeCodeResume<CR>";
      options = {
        desc = "Claude Code: History";
      };
    }

    # Context: Selection
    {
      key = "<leader>as";
      action = "<cmd>ClaudeCodeSelection<CR>";
      options = {
        desc = "Claude Code: Selection (add)";
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

    # Misc
    {
      key = "<leader>ag";
      action = "<cmd>ClaudeCodeCommit<CR>";
      options = {
        desc = "Claude Code: Git Commit";
      };
    }
  ];
}
