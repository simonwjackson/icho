# Kai Plugin Implementation Guide

## Overview

Kai is a focused AI assistant plugin for Neovim that provides surgical code editing capabilities using Claude's CLI. It complements existing Claude Code setups by offering quick, contextual edits with diff preview functionality.

### Key Features
- **Intelligent Action Detection**: Automatically determines whether to replace, insert, or display based on user prompts
- **Diff Preview**: Shows side-by-side comparisons before applying changes
- **Session Continuity**: Maintains conversation context for iterative refinement
- **Modal Interface**: Different behavior in normal vs visual mode
- **JSON Communication**: Structured responses via Claude CLI for reliable parsing

### Design Principles
- Non-disruptive to existing workflows
- Safe changes with visual confirmation
- Efficient context management
- Natural language interaction

## Plugin Architecture

### File Structure
```
kai.nvim/
├── lua/
│   └── kai/
│       ├── init.lua           # Main entry point and setup
│       ├── core.lua           # Core Kai functionality
│       ├── session.lua        # Session management
│       ├── diff.lua           # Diff preview system
│       ├── claude.lua         # Claude CLI interface
│       └── utils.lua          # Utility functions
├── plugin/
│   └── kai.vim               # Plugin initialization
└── README.md
```

### Core Components

#### 1. **init.lua** - Plugin Setup
- Exposes public API
- Handles configuration
- Sets up keybindings
- Initializes session management

#### 2. **core.lua** - Main Logic
- Processes user prompts
- Coordinates between modules
- Manages workflow state
- Handles error cases

#### 3. **session.lua** - Conversation State
- Generates and stores session IDs
- Maintains conversation history
- Provides continuation capabilities
- Persists state across vim sessions

#### 4. **diff.lua** - Preview System
- Creates diff buffers
- Manages preview windows
- Handles user interactions (accept/reject/edit)
- Cleanup and state restoration

#### 5. **claude.lua** - CLI Interface
- Constructs Claude CLI commands
- Parses JSON responses
- Handles system prompt injection
- Manages timeouts and error states

#### 6. **utils.lua** - Helper Functions
- Text manipulation utilities
- Buffer and window helpers
- Path and file operations
- Logging and debug functions

## Implementation Details

### 1. Plugin Initialization (`plugin/kai.vim`)

```vim
" Guard against loading multiple times
if exists('g:loaded_kai')
  finish
endif
let g:loaded_kai = 1

" Initialize the plugin
lua require('kai').setup()
```

### 2. Main Module (`lua/kai/init.lua`)

```lua
local M = {}

-- Default configuration
local default_config = {
  -- Claude CLI path (auto-detected if nil)
  claude_cmd = nil,

  -- Default keybindings
  keymaps = {
    prompt = '<leader>aki',           -- Main Kai prompt
    continue = '<leader>akc',        -- Continue conversation
    repeat_prompt = '<leader>akr',   -- Repeat last prompt
    history = '<leader>akh',         -- Show history
  },

  -- Diff preview settings
  diff = {
    vertical = true,                 -- Vertical split for diff
    auto_close = true,              -- Auto-close preview on accept
    syntax_highlight = true,         -- Enable syntax highlighting
  },

  -- Session settings
  session = {
    persist = true,                  -- Persist sessions across restarts
    max_history = 50,               -- Maximum history entries
    cache_dir = vim.fn.stdpath('cache') .. '/kai',
  },

  -- System prompts for action detection
  system_prompts = {
    action_detection = [[
You are Kai, an AI assistant integrated into Neovim for surgical code editing.

CRITICAL: You must respond with valid JSON in this exact format:
{
  "action": "replace|insert|display",
  "content": "your response content here",
  "confidence": 0.95,
  "reasoning": "brief explanation of why you chose this action"
}

Action Detection Rules:
1. REPLACE: User wants to modify existing code
   - Keywords: "fix", "change", "update", "refactor", "improve", "correct"
   - Example: "fix this bug", "refactor to use async"

2. INSERT: User wants to add new content
   - Keywords: "add", "insert", "create", "generate", "include"
   - Example: "add error handling", "insert a comment"

3. DISPLAY: User wants information without modification
   - Keywords: "explain", "what", "how", "why", "analyze", "show", "tell me"
   - Example: "what does this do?", "explain this function"

Context provided includes:
- Full buffer content for reference
- Cursor position or selected text (focus area)
- File type and project context from CLAUDE.md

Your response content should be:
- For REPLACE: Only the replacement code/text
- For INSERT: Only the new code/text to insert
- For DISPLAY: Explanation or analysis

Be concise and surgical in your edits. Maintain existing code style and conventions.
]],
  },
}

-- Global configuration
M.config = {}

-- Setup function
function M.setup(user_config)
  -- Merge user config with defaults
  M.config = vim.tbl_deep_extend('force', default_config, user_config or {})

  -- Initialize modules
  require('kai.session').setup(M.config.session)
  require('kai.claude').setup(M.config.claude_cmd)

  -- Set up keybindings
  M.setup_keymaps()

  -- Create cache directory
  vim.fn.mkdir(M.config.session.cache_dir, 'p')
end

-- Keybinding setup
function M.setup_keymaps()
  local opts = { noremap = true, silent = true }

  -- Main prompt (works in normal and visual mode)
  vim.keymap.set({'n', 'v'}, M.config.keymaps.prompt, function()
    require('kai.core').prompt()
  end, vim.tbl_extend('force', opts, { desc = 'Kai: Prompt' }))

  -- Continue conversation
  vim.keymap.set({'n', 'v'}, M.config.keymaps.continue, function()
    require('kai.core').continue()
  end, vim.tbl_extend('force', opts, { desc = 'Kai: Continue' }))

  -- Repeat last prompt with new context
  vim.keymap.set({'n', 'v'}, M.config.keymaps.repeat_prompt, function()
    require('kai.core').repeat_prompt()
  end, vim.tbl_extend('force', opts, { desc = 'Kai: Repeat' }))

  -- Show history
  vim.keymap.set('n', M.config.keymaps.history, function()
    require('kai.core').show_history()
  end, vim.tbl_extend('force', opts, { desc = 'Kai: History' }))
end

-- Public API
M.prompt = function() require('kai.core').prompt() end
M.continue = function() require('kai.core').continue() end
M.repeat_prompt = function() require('kai.core').repeat_prompt() end

return M
```

### 3. Core Logic (`lua/kai/core.lua`)

```lua
local session = require('kai.session')
local claude = require('kai.claude')
local diff = require('kai.diff')
local utils = require('kai.utils')

local M = {}

-- Main prompt function
function M.prompt()
  -- Get user input
  local prompt = vim.fn.input('Kai: ')
  if prompt == '' then
    return
  end

  -- Get context
  local context = M.get_context()

  -- Call Claude
  local response = claude.call(prompt, context)
  if not response then
    vim.notify('Kai: Failed to get response', vim.log.levels.ERROR)
    return
  end

  -- Store in session
  session.add_interaction(prompt, response, context)

  -- Handle response
  M.handle_response(response)
end

-- Continue last conversation
function M.continue()
  local last_session_id = session.get_current_session_id()
  if not last_session_id then
    vim.notify('Kai: No previous conversation to continue', vim.log.levels.WARN)
    return
  end

  -- Get user input
  local prompt = vim.fn.input('Kai (continue): ')
  if prompt == '' then
    return
  end

  -- Get context
  local context = M.get_context()

  -- Call Claude with session continuation
  local response = claude.continue_conversation(prompt, context, last_session_id)
  if not response then
    vim.notify('Kai: Failed to continue conversation', vim.log.levels.ERROR)
    return
  end

  -- Store in session
  session.add_interaction(prompt, response, context)

  -- Handle response
  M.handle_response(response)
end

-- Repeat last prompt with new context
function M.repeat_prompt()
  local last_prompt = session.get_last_prompt()
  if not last_prompt then
    vim.notify('Kai: No previous prompt to repeat', vim.log.levels.WARN)
    return
  end

  -- Show last prompt for confirmation/editing
  local prompt = vim.fn.input('Kai (repeat): ', last_prompt)
  if prompt == '' then
    return
  end

  -- Get current context
  local context = M.get_context()

  -- Call Claude (new session)
  local response = claude.call(prompt, context)
  if not response then
    vim.notify('Kai: Failed to get response', vim.log.levels.ERROR)
    return
  end

  -- Store in session
  session.add_interaction(prompt, response, context)

  -- Handle response
  M.handle_response(response)
end

-- Get current context
function M.get_context()
  local context = {}

  -- Get current buffer info
  local bufnr = vim.api.nvim_get_current_buf()
  context.bufnr = bufnr
  context.filename = vim.api.nvim_buf_get_name(bufnr)
  context.filetype = vim.bo[bufnr].filetype

  -- Get cursor position
  local cursor = vim.api.nvim_win_get_cursor(0)
  context.cursor_line = cursor[1]
  context.cursor_col = cursor[2]

  -- Get buffer content
  context.buffer_content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')

  -- Check for visual selection
  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '' then
    context.has_selection = true
    context.selection = utils.get_visual_selection()
    local selection_info = utils.get_selection_info()
    context.selection_start = selection_info.start
    context.selection_end = selection_info.end
  else
    context.has_selection = false
  end

  -- Get CLAUDE.md content if available
  context.claude_md = utils.get_claude_md_content()

  return context
end

-- Handle Claude response
function M.handle_response(response)
  if response.action == 'display' then
    -- Show in floating window
    utils.show_floating_window(response.content, 'Kai Response')

  elseif response.action == 'replace' or response.action == 'insert' then
    -- Show diff preview
    diff.show_preview(response)

  else
    vim.notify('Kai: Unknown action type: ' .. tostring(response.action), vim.log.levels.ERROR)
  end
end

-- Show conversation history
function M.show_history()
  local history = session.get_history()
  if #history == 0 then
    vim.notify('Kai: No conversation history', vim.log.levels.INFO)
    return
  end

  -- Format history for display
  local lines = {}
  for i, interaction in ipairs(history) do
    table.insert(lines, string.format('%d. %s', i, interaction.prompt))
    table.insert(lines, string.format('   → %s (%s)', interaction.response.action, interaction.response.confidence))
    table.insert(lines, '')
  end

  utils.show_floating_window(table.concat(lines, '\n'), 'Kai History')
end

return M
```

### 4. Session Management (`lua/kai/session.lua`)

```lua
local M = {}

-- Session state
local current_session = {
  id = nil,
  interactions = {},
}

-- Configuration
local config = {}

function M.setup(user_config)
  config = user_config or {}

  -- Load existing session if persistence is enabled
  if config.persist then
    M.load_session()
  end
end

-- Generate new session ID
function M.new_session()
  current_session.id = M.generate_uuid()
  current_session.interactions = {}
  return current_session.id
end

-- Generate UUID v4
function M.generate_uuid()
  local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return string.gsub(template, '[xy]', function(c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end)
end

-- Add interaction to current session
function M.add_interaction(prompt, response, context)
  if not current_session.id then
    M.new_session()
  end

  local interaction = {
    prompt = prompt,
    response = response,
    context = context,
    timestamp = os.time(),
  }

  table.insert(current_session.interactions, interaction)

  -- Limit history size
  if config.max_history and #current_session.interactions > config.max_history then
    table.remove(current_session.interactions, 1)
  end

  -- Save session if persistence is enabled
  if config.persist then
    M.save_session()
  end
end

-- Get current session ID
function M.get_current_session_id()
  return current_session.id
end

-- Get last prompt
function M.get_last_prompt()
  if #current_session.interactions > 0 then
    return current_session.interactions[#current_session.interactions].prompt
  end
  return nil
end

-- Get interaction history
function M.get_history()
  return current_session.interactions
end

-- Save session to file
function M.save_session()
  if not config.persist or not config.cache_dir then
    return
  end

  local session_file = config.cache_dir .. '/session.json'
  local data = vim.json.encode(current_session)

  -- Ensure directory exists
  vim.fn.mkdir(vim.fn.fnamemodify(session_file, ':h'), 'p')

  -- Write to file
  local file = io.open(session_file, 'w')
  if file then
    file:write(data)
    file:close()
  end
end

-- Load session from file
function M.load_session()
  if not config.persist or not config.cache_dir then
    return
  end

  local session_file = config.cache_dir .. '/session.json'

  if vim.fn.filereadable(session_file) == 1 then
    local file = io.open(session_file, 'r')
    if file then
      local data = file:read('*a')
      file:close()

      local ok, session = pcall(vim.json.decode, data)
      if ok and session then
        current_session = session
      end
    end
  end
end

return M
```

### 5. Claude CLI Interface (`lua/kai/claude.lua`)

```lua
local utils = require('kai.utils')

local M = {}

-- Configuration
local claude_cmd = 'claude'

function M.setup(cmd)
  if cmd then
    claude_cmd = cmd
  end
end

-- Call Claude with prompt and context
function M.call(prompt, context)
  local system_prompt = M.build_system_prompt(context)
  local user_prompt = M.build_user_prompt(prompt, context)

  local cmd = {
    claude_cmd,
    '--print',
    '--output-format', 'json',
    '--append-system-prompt', system_prompt,
    user_prompt
  }

  return M.execute_claude_command(cmd)
end

-- Continue conversation with session
function M.continue_conversation(prompt, context, session_id)
  local system_prompt = M.build_system_prompt(context)
  local user_prompt = M.build_user_prompt(prompt, context)

  local cmd = {
    claude_cmd,
    '--print',
    '--output-format', 'json',
    '--append-system-prompt', system_prompt,
    '--session-id', session_id,
    '--continue',
    user_prompt
  }

  return M.execute_claude_command(cmd)
end

-- Build system prompt for action detection
function M.build_system_prompt(context)
  local config = require('kai').config
  local base_prompt = config.system_prompts.action_detection

  -- Add context-specific information
  local context_info = string.format([[

CURRENT EDITING CONTEXT:
- File: %s
- File type: %s
- Cursor at line %d, column %d
- Buffer has %d lines
]],
    utils.get_relative_path(context.filename),
    context.filetype,
    context.cursor_line,
    context.cursor_col,
    vim.api.nvim_buf_line_count(context.bufnr)
  )

  if context.has_selection then
    context_info = context_info .. string.format([[
- SELECTED TEXT (lines %d-%d):
%s
]],
      context.selection_start.line,
      context.selection_end.line,
      context.selection
    )
  end

  -- Include CLAUDE.md if available
  if context.claude_md then
    context_info = context_info .. '\n\nCLAUDE.md CONTEXT:\n' .. context.claude_md
  end

  return base_prompt .. context_info
end

-- Build user prompt with full context
function M.build_user_prompt(prompt, context)
  local full_prompt = string.format([[
INSTRUCTION: %s

FULL BUFFER CONTENT:
%s
]], prompt, context.buffer_content)

  if context.has_selection then
    full_prompt = full_prompt .. string.format([[

FOCUS: User has selected lines %d-%d. Make targeted changes to this selection unless instructed otherwise.
]],
      context.selection_start.line,
      context.selection_end.line
    )
  else
    full_prompt = full_prompt .. string.format([[

FOCUS: User's cursor is at line %d. Make targeted changes based on cursor location unless instructed otherwise.
]], context.cursor_line)
  end

  return full_prompt
end

-- Execute Claude command and parse response
function M.execute_claude_command(cmd)
  -- Escape command arguments
  local escaped_cmd = {}
  for i, arg in ipairs(cmd) do
    -- Simple shell escaping - in production you'd want more robust escaping
    if arg:match('[%s%$%`%!%&%|%<%>%(%)]') then
      escaped_cmd[i] = "'" .. arg:gsub("'", "'\"'\"'") .. "'"
    else
      escaped_cmd[i] = arg
    end
  end

  local command = table.concat(escaped_cmd, ' ')

  -- Execute command
  local handle = io.popen(command .. ' 2>&1')
  if not handle then
    vim.notify('Kai: Failed to execute Claude command', vim.log.levels.ERROR)
    return nil
  end

  local output = handle:read('*a')
  local success = handle:close()

  if not success then
    vim.notify('Kai: Claude command failed: ' .. output, vim.log.levels.ERROR)
    return nil
  end

  -- Parse JSON response
  local ok, response = pcall(vim.json.decode, output)
  if not ok then
    vim.notify('Kai: Failed to parse Claude response: ' .. output, vim.log.levels.ERROR)
    return nil
  end

  -- Validate response structure
  if not M.validate_response(response) then
    vim.notify('Kai: Invalid response format from Claude', vim.log.levels.ERROR)
    return nil
  end

  return response
end

-- Validate Claude response
function M.validate_response(response)
  if type(response) ~= 'table' then
    return false
  end

  if not response.action or not response.content then
    return false
  end

  local valid_actions = { 'replace', 'insert', 'display' }
  local action_valid = false
  for _, valid_action in ipairs(valid_actions) do
    if response.action == valid_action then
      action_valid = true
      break
    end
  end

  return action_valid
end

return M
```

### 6. Diff Preview System (`lua/kai/diff.lua`)

```lua
local utils = require('kai.utils')

local M = {}

-- Current preview state
local preview_state = {
  original_buf = nil,
  preview_buf = nil,
  original_win = nil,
  preview_win = nil,
  response = nil,
  context = nil,
}

-- Show diff preview
function M.show_preview(response)
  -- Store current context
  local context = require('kai.core').get_context()
  preview_state.response = response
  preview_state.context = context

  -- Create preview content based on action
  local preview_content
  if response.action == 'replace' then
    preview_content = M.create_replacement_preview(response, context)
  elseif response.action == 'insert' then
    preview_content = M.create_insertion_preview(response, context)
  else
    vim.notify('Kai: Cannot preview action: ' .. response.action, vim.log.levels.ERROR)
    return
  end

  -- Set up diff view
  M.setup_diff_view(preview_content, context)

  -- Set up keybindings for preview
  M.setup_preview_keybindings()

  -- Show instructions
  vim.notify('Kai: [y/CR]Accept [n/Esc]Reject [e]Edit [c]Continue', vim.log.levels.INFO)
end

-- Create replacement preview
function M.create_replacement_preview(response, context)
  if context.has_selection then
    -- Replace selected text
    local lines = vim.split(context.buffer_content, '\n')
    local new_lines = {}

    -- Add lines before selection
    for i = 1, context.selection_start.line - 1 do
      table.insert(new_lines, lines[i])
    end

    -- Add replacement content
    local replacement_lines = vim.split(response.content, '\n')
    for _, line in ipairs(replacement_lines) do
      table.insert(new_lines, line)
    end

    -- Add lines after selection
    for i = context.selection_end.line + 1, #lines do
      table.insert(new_lines, lines[i])
    end

    return table.concat(new_lines, '\n')
  else
    -- Replace at cursor line
    local lines = vim.split(context.buffer_content, '\n')
    local replacement_lines = vim.split(response.content, '\n')

    -- Replace the current line
    for i, line in ipairs(replacement_lines) do
      if i == 1 then
        lines[context.cursor_line] = line
      else
        table.insert(lines, context.cursor_line + i - 1, line)
      end
    end

    return table.concat(lines, '\n')
  end
end

-- Create insertion preview
function M.create_insertion_preview(response, context)
  local lines = vim.split(context.buffer_content, '\n')
  local insert_lines = vim.split(response.content, '\n')

  local insert_position
  if context.has_selection then
    -- Insert after selection
    insert_position = context.selection_end.line
  else
    -- Insert after cursor line
    insert_position = context.cursor_line
  end

  -- Insert new content
  for i = #insert_lines, 1, -1 do
    table.insert(lines, insert_position + 1, insert_lines[i])
  end

  return table.concat(lines, '\n')
end

-- Set up diff view
function M.setup_diff_view(preview_content, context)
  -- Store original buffer
  preview_state.original_buf = context.bufnr
  preview_state.original_win = vim.api.nvim_get_current_win()

  -- Create preview buffer
  preview_state.preview_buf = vim.api.nvim_create_buf(false, true)

  -- Set preview buffer content
  local preview_lines = vim.split(preview_content, '\n')
  vim.api.nvim_buf_set_lines(preview_state.preview_buf, 0, -1, false, preview_lines)

  -- Set buffer properties
  vim.bo[preview_state.preview_buf].filetype = context.filetype
  vim.bo[preview_state.preview_buf].modifiable = false

  -- Create vertical split
  vim.cmd('vsplit')
  preview_state.preview_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(preview_state.preview_win, preview_state.preview_buf)

  -- Set up diff mode
  vim.api.nvim_set_current_win(preview_state.original_win)
  vim.cmd('diffthis')
  vim.api.nvim_set_current_win(preview_state.preview_win)
  vim.cmd('diffthis')

  -- Focus on the diff area if there's a selection
  if context.has_selection then
    vim.api.nvim_win_set_cursor(preview_state.preview_win, {context.selection_start.line, 0})
  else
    vim.api.nvim_win_set_cursor(preview_state.preview_win, {context.cursor_line, 0})
  end
end

-- Set up preview keybindings
function M.setup_preview_keybindings()
  local opts = { noremap = true, silent = true, buffer = preview_state.preview_buf }

  -- Accept changes
  vim.keymap.set('n', '<CR>', M.accept_changes, opts)
  vim.keymap.set('n', 'y', M.accept_changes, opts)

  -- Reject changes
  vim.keymap.set('n', '<Esc>', M.reject_changes, opts)
  vim.keymap.set('n', 'n', M.reject_changes, opts)

  -- Edit changes
  vim.keymap.set('n', 'e', M.edit_changes, opts)

  -- Continue conversation
  vim.keymap.set('n', 'c', M.continue_from_preview, opts)
end

-- Accept changes
function M.accept_changes()
  if not preview_state.preview_buf then
    return
  end

  -- Get preview content
  local preview_lines = vim.api.nvim_buf_get_lines(preview_state.preview_buf, 0, -1, false)

  -- Apply to original buffer
  vim.api.nvim_buf_set_lines(preview_state.original_buf, 0, -1, false, preview_lines)

  -- Clean up
  M.cleanup_preview()

  vim.notify('Kai: Changes applied', vim.log.levels.INFO)
end

-- Reject changes
function M.reject_changes()
  M.cleanup_preview()
  vim.notify('Kai: Changes rejected', vim.log.levels.INFO)
end

-- Edit changes
function M.edit_changes()
  if not preview_state.preview_buf then
    return
  end

  -- Make preview buffer modifiable
  vim.bo[preview_state.preview_buf].modifiable = true

  -- Switch to insert mode
  vim.cmd('startinsert')

  vim.notify('Kai: Edit mode - save to apply changes', vim.log.levels.INFO)

  -- Set up save handler
  vim.api.nvim_create_autocmd('BufWriteCmd', {
    buffer = preview_state.preview_buf,
    once = true,
    callback = function()
      M.accept_changes()
    end,
  })
end

-- Continue conversation from preview
function M.continue_from_preview()
  -- Store current state
  local current_response = preview_state.response

  -- Clean up preview first
  M.cleanup_preview()

  -- Trigger continue
  require('kai.core').continue()
end

-- Clean up preview
function M.cleanup_preview()
  -- Turn off diff mode
  if preview_state.original_win and vim.api.nvim_win_is_valid(preview_state.original_win) then
    vim.api.nvim_set_current_win(preview_state.original_win)
    vim.cmd('diffoff')
  end

  if preview_state.preview_win and vim.api.nvim_win_is_valid(preview_state.preview_win) then
    vim.api.nvim_set_current_win(preview_state.preview_win)
    vim.cmd('diffoff')
  end

  -- Close preview window
  if preview_state.preview_win and vim.api.nvim_win_is_valid(preview_state.preview_win) then
    vim.api.nvim_win_close(preview_state.preview_win, true)
  end

  -- Delete preview buffer
  if preview_state.preview_buf and vim.api.nvim_buf_is_valid(preview_state.preview_buf) then
    vim.api.nvim_buf_delete(preview_state.preview_buf, { force = true })
  end

  -- Return focus to original window
  if preview_state.original_win and vim.api.nvim_win_is_valid(preview_state.original_win) then
    vim.api.nvim_set_current_win(preview_state.original_win)
  end

  -- Reset state
  preview_state = {
    original_buf = nil,
    preview_buf = nil,
    original_win = nil,
    preview_win = nil,
    response = nil,
    context = nil,
  }
end

return M
```

### 7. Utility Functions (`lua/kai/utils.lua`)

```lua
local M = {}

-- Get visual selection text
function M.get_visual_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  local start_line = start_pos[2]
  local start_col = start_pos[3]
  local end_line = end_pos[2]
  local end_col = end_pos[3]

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  if #lines == 0 then
    return ""
  end

  if #lines == 1 then
    return string.sub(lines[1], start_col, end_col)
  else
    lines[1] = string.sub(lines[1], start_col)
    lines[#lines] = string.sub(lines[#lines], 1, end_col)
    return table.concat(lines, '\n')
  end
end

-- Get selection info (line numbers)
function M.get_selection_info()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  return {
    start = { line = start_pos[2], col = start_pos[3] },
    ['end'] = { line = end_pos[2], col = end_pos[3] },
  }
end

-- Get relative path from current working directory
function M.get_relative_path(path)
  local cwd = vim.fn.getcwd()
  if path:sub(1, #cwd) == cwd then
    return path:sub(#cwd + 2) -- +2 to skip the slash
  end
  return path
end

-- Find and read CLAUDE.md files
function M.get_claude_md_content()
  local content = {}

  -- Check for global CLAUDE.md
  local global_claude = vim.fn.expand('~/.claude/CLAUDE.md')
  if vim.fn.filereadable(global_claude) == 1 then
    local global_content = M.read_file(global_claude)
    if global_content then
      table.insert(content, 'GLOBAL CLAUDE.md:\n' .. global_content)
    end
  end

  -- Check for project CLAUDE.md
  local current_dir = vim.fn.getcwd()
  while current_dir ~= '/' do
    local project_claude = current_dir .. '/CLAUDE.md'
    if vim.fn.filereadable(project_claude) == 1 then
      local project_content = M.read_file(project_claude)
      if project_content then
        table.insert(content, 'PROJECT CLAUDE.md:\n' .. project_content)
      end
      break
    end
    current_dir = vim.fn.fnamemodify(current_dir, ':h')
  end

  return #content > 0 and table.concat(content, '\n\n') or nil
end

-- Read file content
function M.read_file(path)
  local file = io.open(path, 'r')
  if not file then
    return nil
  end

  local content = file:read('*a')
  file:close()
  return content
end

-- Show floating window with content
function M.show_floating_window(content, title)
  local lines = vim.split(content, '\n')

  -- Calculate window size
  local width = math.min(80, vim.o.columns - 10)
  local height = math.min(#lines + 2, vim.o.lines - 10)

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = 'markdown'

  -- Create window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = 'rounded',
    title = title or 'Kai',
    title_pos = 'center',
  })

  -- Set up close keybindings
  local close_keys = { 'q', '<Esc>', '<CR>' }
  for _, key in ipairs(close_keys) do
    vim.keymap.set('n', key, function()
      vim.api.nvim_win_close(win, true)
    end, { buffer = buf, noremap = true, silent = true })
  end
end

-- Debug logging
function M.log(message, level)
  level = level or vim.log.levels.INFO
  vim.notify('Kai: ' .. tostring(message), level)
end

return M
```

## Testing Strategy

### Isolated Environment Setup

1. **Create test directory:**
```bash
mkdir -p ~/kai-test
cd ~/kai-test
```

2. **Create minimal init.lua:**
```lua
-- ~/kai-test/init.lua
vim.opt.runtimepath:prepend('~/path/to/kai.nvim')

require('kai').setup({
  keymaps = {
    prompt = '<leader>ak',
    continue = '<leader>akc',
    repeat_prompt = '<leader>akr',
    history = '<leader>akh',
  },
})
```

3. **Test with isolated nvim:**
```bash
nix run nixpkgs#nvim -- -u ~/kai-test/init.lua test.py
```

### Test Cases

#### 1. **Replace Action Test**
```python
# test.py
def broken_function():
    return None  # This is broken
```

1. Select the function
2. `<leader>ak` "fix this function to return 42"
3. Should show diff with corrected function
4. Accept with `<CR>`

#### 2. **Insert Action Test**
```python
# test.py
def calculate(x, y):
    return x + y
```

1. Position cursor at end of function
2. `<leader>ak` "add error handling for invalid inputs"
3. Should show diff with added error handling
4. Accept or edit as needed

#### 3. **Display Action Test**
```python
# test.py
def complex_algorithm(data):
    result = []
    for item in data:
        if item % 2 == 0:
            result.append(item * 2)
    return result
```

1. Select the function
2. `<leader>ak` "explain what this does"
3. Should show explanation in floating window

#### 4. **Continue Test**
1. Use any replace/insert action
2. Accept changes
3. `<leader>akc` "now add docstring"
4. Should build on previous change

### Debug Mode

Add debug configuration for development:

```lua
-- In init.lua setup
require('kai').setup({
  debug = true,  -- Enable debug logging
  claude_cmd = 'echo', -- Mock Claude for testing
})
```

## Future Nix Integration

Once the plugin is stable, integration into your nixvim config:

### 1. **Convert to Nix Module**
```nix
# config/agents/kai.nix
{ pkgs, ... }: {
  extraPackages = [
    pkgs.claude-code  # Ensure Claude CLI is available
  ];

  extraPlugins = [
    # Add kai.nvim as local plugin or from GitHub
  ];

  extraConfigLua = ''
    require('kai').setup({
      claude_cmd = "${pkgs.claude-code}/bin/claude",
      keymaps = {
        prompt = '<leader>ak',
        continue = '<leader>akc',
        repeat_prompt = '<leader>akr',
        history = '<leader>akh',
      },
    })
  '';
}
```

### 2. **Add to Main Config**
```nix
# config/agents/default.nix
{
  imports = [
    ./kai.nix
    # ... other imports
  ];
}
```

## Development Workflow

### 1. **Rapid Iteration**
```bash
# Test changes quickly
cd ~/kai-test
nvim -u init.lua test.py

# In vim, reload plugin
:lua package.loaded['kai'] = nil
:lua require('kai').setup()
```

### 2. **Debug Commands**
```vim
:lua require('kai.utils').log('Debug message')
:lua print(vim.inspect(require('kai.session').get_history()))
```

### 3. **Performance Testing**
- Test with large files (>1000 lines)
- Test rapid-fire requests
- Monitor memory usage with `:lua collectgarbage('collect')`

## Key Implementation Notes

1. **Error Handling**: All Claude CLI calls should be wrapped in pcall()
2. **Escaping**: Shell command arguments need proper escaping
3. **Cleanup**: Always clean up temporary buffers and windows
4. **State Management**: Session state should persist across vim restarts
5. **Performance**: Consider caching Claude responses for repeated requests
6. **Security**: Validate all Claude responses before applying changes

This implementation guide provides a complete blueprint for building Kai as a standalone Neovim plugin with all the features discussed, ready for iterative development and eventual integration into your nixvim configuration.

## Original Idea

https://danielmiessler.com/blog/neovim-claude-ai-plugin
