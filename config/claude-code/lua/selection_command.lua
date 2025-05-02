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