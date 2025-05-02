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