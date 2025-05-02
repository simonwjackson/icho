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

    -- Define a custom command to send the current file to Claude Code
    vim.api.nvim_create_user_command('ClaudeCodeFile', function()
      -- Get the current buffer name
      local buffer = vim.api.nvim_get_current_buf()
      local filename = vim.api.nvim_buf_get_name(buffer)
       -- Check if the Claude Code buffer exists
      local claude_code = require('claude-code')
      local bufnr = claude_code.claude_code.bufnr
       -- Open Claude Code if not already open
      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        claude_code.toggle()
        -- Wait for Claude to initialize
        vim.defer_fn(function()
          -- Send the READ command to the terminal
          vim.api.nvim_chan_send(vim.b.terminal_job_id, "READ " .. filename .. "\n\n")
        end, 1000) -- Adjust timeout as needed
      else
        -- Claude Code is already open, send the command
        -- Find the terminal job ID
        local win_ids = vim.fn.win_findbuf(bufnr)
        if #win_ids > 0 then
          vim.api.nvim_set_current_win(win_ids[1])
        else
          -- Open Claude Code window if not visible
          claude_code.toggle()
        end
        -- Send the READ command
        vim.defer_fn(function()
          vim.api.nvim_chan_send(vim.b.terminal_job_id, "READ " .. filename .. "\n\n")
        end, 100)
      end
    end, {})

    -- Define a command to send the current visual selection with file path and line numbers to Claude Code
    vim.api.nvim_create_user_command('ClaudeCodeSelection', function()
      -- Get the current visual selection
      local start_line, start_col = unpack(vim.api.nvim_buf_get_mark(0, '<'))
      local end_line, end_col = unpack(vim.api.nvim_buf_get_mark(0, '>'))
       -- Adjust cols for proper character indexing
      start_col = start_col + 1
      end_col = end_col + 1
       -- Get the selected text
      local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
      if #lines == 0 then
        vim.notify('No text selected', vim.log.levels.ERROR)
        return
      end
       -- Adjust the first and last line for partial selection
      if #lines == 1 then
        lines[1] = string.sub(lines[1], start_col, end_col)
      else
        lines[1] = string.sub(lines[1], start_col)
        lines[#lines] = string.sub(lines[#lines], 1, end_col)
      end
       -- Combine the lines with newlines
      local selected_text = table.concat(lines, '\n')
       -- Get current buffer file path (relative to cwd if possible)
      local full_path = vim.api.nvim_buf_get_name(0)
      local cwd = vim.fn.getcwd()
      local rel_path = full_path
       -- Try to get relative path if file is under cwd
      if full_path:sub(1, #cwd) == cwd then
        rel_path = full_path:sub(#cwd + 2) -- +2 to skip the slash after cwd
      end
       -- Create formatted message with file info and selection
      local message = string.format("From file %s (lines %d-%d):\n\n```\n%s\n```\n\n",
                                   rel_path, start_line, end_line, selected_text)
       -- Check if the Claude Code buffer exists
      local claude_code = require('claude-code')
      local bufnr = claude_code.claude_code.bufnr
       -- Open Claude Code if not already open
      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        claude_code.toggle()
        -- Wait for Claude to initialize
        vim.defer_fn(function()
          -- Send the formatted message to the terminal
          vim.api.nvim_chan_send(vim.b.terminal_job_id, message .. "\n\n")
        end, 1000) -- Adjust timeout as needed
      else
        -- Claude Code is already open, send the message
        -- Find the terminal job ID
        local win_ids = vim.fn.win_findbuf(bufnr)
        if #win_ids > 0 then
          vim.api.nvim_set_current_win(win_ids[1])
        else
          -- Open Claude Code window if not visible
          claude_code.toggle()
        end
        -- Send the formatted message
        vim.defer_fn(function()
          vim.api.nvim_chan_send(vim.b.terminal_job_id, message .. "\n\n")
        end, 100)
      end
    end, { range = true })

    -- Define a command to select multiple files and send them to Claude Code
    vim.api.nvim_create_user_command('ClaudeCodeFiles', function()
      local telescope = require('telescope.builtin')
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')

      -- Open Telescope file picker with multi-select
      telescope.find_files({
        attach_mappings = function(prompt_bufnr, map)
          -- Use default selection mappings (Tab to select)

          -- Override the default enter action to send selected files to Claude
          actions.select_default:replace(function()
            -- Get all selected entries
            local picker = action_state.get_current_picker(prompt_bufnr)
            local selections = picker:get_multi_selection()

            -- If no selections, get current entry
            if #selections == 0 then
              local entry = action_state.get_selected_entry()
              if entry then
                selections = { entry }
              end
            end

            -- Close telescope
            actions.close(prompt_bufnr)

            -- If no files selected, exit
            if #selections == 0 then
              vim.notify("No files selected for Claude", vim.log.levels.WARN)
              return
            end

            -- Extract file paths
            local files_to_send = {}
            for _, selection in ipairs(selections) do
              table.insert(files_to_send, selection.value)
            end

            -- Initialize Claude Code
            local claude_code = require('claude-code')
            local bufnr = claude_code.claude_code.bufnr

            -- Open Claude Code if not already open
            if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
              claude_code.toggle()
              -- Wait for Claude to initialize before sending files
              vim.defer_fn(function()
                -- Send each file
                for _, file in ipairs(files_to_send) do
                  vim.api.nvim_chan_send(vim.b.terminal_job_id, "Context: " .. file .. "\n")
                  -- Small delay between files to ensure proper processing
                  vim.cmd("sleep 100m")
                end

                vim.notify("Sent " .. #files_to_send .. " files to Claude Code", vim.log.levels.INFO)
              end, 1000)
            else
              -- Claude Code is already open, activate window
              local win_ids = vim.fn.win_findbuf(bufnr)
              if #win_ids > 0 then
                vim.api.nvim_set_current_win(win_ids[1])
              else
                claude_code.toggle()
              end

              -- Send the files
              vim.defer_fn(function()
                for _, file in ipairs(files_to_send) do
                  vim.api.nvim_chan_send(vim.b.terminal_job_id, "READ " .. file .. "\n")
                  vim.cmd("sleep 100m")
                end

                vim.notify("Sent " .. #files_to_send .. " files to Claude Code", vim.log.levels.INFO)
              end, 100)
            end
          end)

          return true
        end,
        prompt_title = "Select Files for Claude Code (Tab to select multiple, Enter to confirm)",
      })
    end, {})

    -- Define a command to select directories and send them to Claude Code
    vim.api.nvim_create_user_command('ClaudeCodeDirectories', function()
      local telescope = require('telescope.builtin')
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')

      -- Open Telescope directory picker with multi-select
      telescope.find_files({
        attach_mappings = function(prompt_bufnr, map)
          -- Use default selection mappings (Tab to select)

          -- Override the default enter action to send selected directories to Claude
          actions.select_default:replace(function()
            -- Get all selected entries
            local picker = action_state.get_current_picker(prompt_bufnr)
            local selections = picker:get_multi_selection()

            -- If no selections, get current entry
            if #selections == 0 then
              local entry = action_state.get_selected_entry()
              if entry then
                selections = { entry }
              end
            end

            -- Close telescope
            actions.close(prompt_bufnr)

            -- If no directories selected, exit
            if #selections == 0 then
              vim.notify("No directories selected for Claude", vim.log.levels.WARN)
              return
            end

            -- Extract directory paths
            local dirs_to_send = {}
            for _, selection in ipairs(selections) do
              table.insert(dirs_to_send, selection.value)
            end

            -- Initialize Claude Code
            local claude_code = require('claude-code')
            local bufnr = claude_code.claude_code.bufnr

            -- Open Claude Code if not already open
            if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
              claude_code.toggle()
              -- Wait for Claude to initialize before sending directories
              vim.defer_fn(function()
                -- Send each directory
                for _, dir in ipairs(dirs_to_send) do
                  vim.api.nvim_chan_send(vim.b.terminal_job_id, "Context: " .. dir .. "/**/*\n")
                  -- Small delay between directories to ensure proper processing
                  vim.cmd("sleep 100m")
                end

                vim.notify("Sent " .. #dirs_to_send .. " directories to Claude Code", vim.log.levels.INFO)
              end, 1000)
            else
              -- Claude Code is already open, activate window
              local win_ids = vim.fn.win_findbuf(bufnr)
              if #win_ids > 0 then
                vim.api.nvim_set_current_win(win_ids[1])
              else
                claude_code.toggle()
              end

              -- Send the directories
              vim.defer_fn(function()
                for _, dir in ipairs(dirs_to_send) do
                  vim.api.nvim_chan_send(vim.b.terminal_job_id, "Context: Directory structure for " .. dir .. "\n")
                  vim.api.nvim_chan_send(vim.b.terminal_job_id, "LS " .. dir .. "\n\n")
                  -- Small delay between directories to ensure proper processing
                  vim.cmd("sleep 100m")
                end

                vim.notify("Sent " .. #dirs_to_send .. " directories to Claude Code", vim.log.levels.INFO)
              end, 100)
            end
          end)

          return true
        end,
        find_command = { "find", ".", "-type", "d", "-not", "-path", "*/\\.*" },
        prompt_title = "Select Directories for Claude Code (Tab to select multiple, Enter to confirm)",
      })
    end, {})
  '';

  # Add convenient keymaps for Claude AI actions
  keymaps = [
    # Chats
    {
      key = "<c-s-space>";
      action = "<cmd>ClaudeCode<CR>";
      options = {
        desc = "Claude Code: Toggle";
      };
    }
    {
      key = "<c-space>";
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
