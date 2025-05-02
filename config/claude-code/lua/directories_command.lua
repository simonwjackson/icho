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