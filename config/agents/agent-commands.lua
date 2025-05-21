-- Utility functions for path handling
local function get_relative_path(path)
	local cwd = vim.fn.getcwd()
	local rel_path = path

	if path:sub(1, #cwd) == cwd then
		rel_path = path:sub(#cwd + 2) -- +2 to skip the slash after cwd
	end

	return rel_path
end

-- Claude Code integration functions
local function ensure_claude_open()
	local claude_code = require("claude-code")
	local bufnr = claude_code.claude_code.bufnr

	-- Open Claude Code if not already open
	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
		claude_code.toggle()
		bufnr = claude_code.claude_code.bufnr

		-- Set the buffer filetype to "claude-code" so edgy can manage it
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_buf_set_option(bufnr, "filetype", "claude-code")
		end
	else
		-- Find Claude window and focus it
		local win_ids = vim.fn.win_findbuf(bufnr)
		if #win_ids > 0 then
			vim.api.nvim_set_current_win(win_ids[1])
		else
			-- Open Claude Code window if not visible
			claude_code.toggle()

			-- Set the buffer filetype to "claude-code" so edgy can manage it
			if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
				vim.api.nvim_buf_set_option(bufnr, "filetype", "claude-code")
			end
		end
	end

	return claude_code.claude_code.bufnr
end

local function send_to_claude(content)
	local claude_code = require("claude-code")
	local bufnr = claude_code.claude_code.bufnr

	-- Check if Claude Code buffer exists
	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
		bufnr = ensure_claude_open()
	end

	-- Find Claude Code window
	local win_ids = vim.fn.win_findbuf(bufnr)
	if #win_ids > 0 then
		-- Focus the Claude Code window
		vim.api.nvim_set_current_win(win_ids[1])

		-- Get buffer and window info
		local term_buf = vim.api.nvim_win_get_buf(win_ids[1])

		-- Use the current buffer's terminal channel
		local term_channel = vim.b[term_buf].terminal_job_id
		if term_channel then
			-- Check if terminal is in insert mode by looking for "-- INSERT --" in the buffer
			local in_insert_mode = false

			-- Save current window to restore it later
			local current_win = vim.api.nvim_get_current_win()

			-- Temporarily capture the terminal contents
			local lines = vim.api.nvim_buf_get_lines(term_buf, 0, -1, false)
			local term_text = table.concat(lines, "\n")

			-- Check if "-- INSERT --" or "failed to connect" appears in the terminal
			if term_text:match("-- INSERT --") or term_text:match("failed to connect") then
				in_insert_mode = true
			end

			-- If not in insert mode, send 'i' to enter it
			if not in_insert_mode then
				vim.fn.chansend(term_channel, "i")
				-- Small delay to ensure mode change
				vim.cmd("sleep 10m")
			end

			-- Then send the content
			vim.fn.chansend(term_channel, content .. "\n")

			-- Restore original window focus
			vim.api.nvim_set_current_win(current_win)
		else
			-- Fallback: Use feedkeys
			vim.cmd("startinsert")
			vim.api.nvim_put(vim.split(content, "\n"), "", true, true)
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", true)
		end
	end
end

-- Buffer management functions
local function get_agent_buffer()
	-- Check if agent-input buffer already exists
	local agent_buf = nil
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(buf):match("agent%-input$") then
			agent_buf = buf
			break
		end
	end

	-- Create agent-input buffer if it doesn't exist
	if not agent_buf or not vim.api.nvim_buf_is_valid(agent_buf) then
		-- Create a new buffer for agent input
		agent_buf = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_buf_set_name(agent_buf, "agent-input")

		-- Set buffer options
		vim.bo[agent_buf].buftype = "nofile"
		vim.bo[agent_buf].filetype = "markdown"
		vim.bo[agent_buf].swapfile = false
		vim.bo[agent_buf].modified = false
		vim.bo[agent_buf].modifiable = true
	end

	return agent_buf
end

-- Window management functions
-- Function to resize agent window based on focus
local function resize_agent_window(win_id)
	if not vim.api.nvim_win_is_valid(win_id) then
		return
	end

	local is_current = (vim.api.nvim_get_current_win() == win_id)

	if is_current then
		-- If agent window is active, set to 38% of screen height
		local screen_height = vim.api.nvim_get_option("lines")
		local height = math.floor(screen_height * 0.38)
		vim.api.nvim_win_set_height(win_id, height)
	else
		-- If agent window is inactive, set to 10 rows
		vim.api.nvim_win_set_height(win_id, 10)
	end
end

local function get_agent_window(agent_buf)
	agent_buf = agent_buf or get_agent_buffer()

	-- Find agent-input window if it exists
	local agent_win = nil
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == agent_buf then
			agent_win = win
			break
		end
	end

	-- Create new window if agent window doesn't exist
	if not agent_win then
		-- Set the buffer filetype so edgy can manage it
		vim.api.nvim_buf_set_option(agent_buf, "filetype", "agent-input")

		-- Open the buffer in a new window - edgy will place it in the right pane
		vim.cmd("new")
		agent_win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(agent_win, agent_buf)

		-- Create autocommands to resize the window when it gains or loses focus
		local agent_augroup = vim.api.nvim_create_augroup("AgentWindowResize", { clear = true })

		vim.api.nvim_create_autocmd({ "WinEnter", "WinLeave" }, {
			group = agent_augroup,
			callback = function()
				-- Only resize if the agent window still exists
				if vim.api.nvim_win_is_valid(agent_win) then
					resize_agent_window(agent_win)
				end
			end,
		})

		-- Initial resize based on current focus
		resize_agent_window(agent_win)
	else
		-- Focus the existing agent window
		vim.api.nvim_set_current_win(agent_win)

		-- Resize based on focus
		resize_agent_window(agent_win)
	end

	return agent_win
end

-- Content handling functions
local function update_agent_buffer(agent_buf, content)
	-- If buffer is not empty, append to it; otherwise set the initial content
	if vim.api.nvim_buf_line_count(agent_buf) > 1 then
		-- Append command text to the end of the buffer
		local end_line = vim.api.nvim_buf_line_count(agent_buf)
		-- Add a separator line if the buffer doesn't end with empty lines
		local last_line = vim.api.nvim_buf_get_lines(agent_buf, end_line - 1, end_line, false)[1]
		if last_line and last_line ~= "" then
			vim.api.nvim_buf_set_lines(agent_buf, end_line, end_line, false, { "" })
			end_line = end_line + 1
		end
		vim.api.nvim_buf_set_lines(agent_buf, end_line, end_line, false, vim.split(content, "\n"))
	else
		-- Clear buffer and set the command text at the start (initial case)
		vim.api.nvim_buf_set_lines(agent_buf, 0, -1, false, vim.split(content, "\n"))
	end

	-- Mark the buffer as not modified to prevent "unsaved changes" prompts
	vim.bo[agent_buf].modified = false

	return agent_buf
end

local function focus_end_of_buffer(win_id, buf_id)
	-- Move cursor to the end of the buffer
	local last_line = vim.api.nvim_buf_line_count(buf_id)
	vim.api.nvim_win_set_cursor(win_id, { last_line, 0 })
end

local function setup_agent_ui()
	-- Ensure Claude is open
	ensure_claude_open()

	-- Get or create agent buffer
	local agent_buf = get_agent_buffer()

	-- Get or create agent window
	local agent_win = get_agent_window(agent_buf)

	return agent_buf, agent_win
end

local function cleanup_agent_ui()
	-- Find agent buffer
	local agent_buf = nil
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(buf):match("agent%-input$") then
			agent_buf = buf
			break
		end
	end

	if not agent_buf or not vim.api.nvim_buf_is_valid(agent_buf) then
		return
	end

	-- Clean up the autocommand group
	pcall(function()
		vim.api.nvim_del_augroup_by_name("AgentWindowResize")
	end)

	-- Close agent-input window
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == agent_buf then
			vim.api.nvim_win_close(win, true)
			break
		end
	end

	-- Delete the agent-input buffer
	vim.api.nvim_buf_delete(agent_buf, { force = true })
end

-- =============================================================================
-- Command Implementations
-- =============================================================================

-- Define a custom command to send the current file to a buffer below Claude Code
vim.api.nvim_create_user_command("ClaudeCodeFile", function()
	-- Get the current buffer name
	local buffer = vim.api.nvim_get_current_buf()
	local full_path = vim.api.nvim_buf_get_name(buffer)
	local rel_path = get_relative_path(full_path)

	-- Read file content
	local file = io.open(full_path, "r")
	if file then
		file:close()
	end

	-- Create command text
	local command_text = "READ " .. rel_path .. "\n"

	-- Setup UI
	local agent_buf, agent_win = setup_agent_ui()

	-- Update buffer with command text
	update_agent_buffer(agent_buf, command_text)

	-- Focus end of buffer
	focus_end_of_buffer(agent_win, agent_buf)
end, {})

-- Define a command to send agent-input content to claude-code terminal and close agent-input buffer
vim.api.nvim_create_user_command("ClaudeCodeSend", function()
	-- Check if agent-input buffer exists
	local agent_buf = nil
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(buf):match("agent%-input$") then
			agent_buf = buf
			break
		end
	end

	if not agent_buf or not vim.api.nvim_buf_is_valid(agent_buf) then
		vim.notify("No agent-input buffer found", vim.log.levels.ERROR)
		return
	end

	-- Get content from agent-input buffer
	local content = vim.api.nvim_buf_get_lines(agent_buf, 0, -1, false)
	if #content == 0 then
		vim.notify("agent-input buffer is empty", vim.log.levels.ERROR)
		return
	end

	-- Get full content from agent-input buffer
	local full_content = table.concat(content, "\n")

	-- Send to Claude
	send_to_claude(full_content)

	-- Clear the agent-input buffer content but keep the window open
	vim.api.nvim_buf_set_lines(agent_buf, 0, -1, false, {})
	vim.bo[agent_buf].modified = false
end, {})

-- Define a custom command to send the current selection to a buffer below Claude Code
vim.api.nvim_create_user_command("ClaudeCodeSelection", function()
	-- Get the current visual selection
	local mode = vim.api.nvim_get_mode().mode
	if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
		vim.notify("This command requires a visual selection", vim.log.levels.ERROR)
		return
	end

	-- Get start and end positions of visual selection
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local start_line, start_col = start_pos[2], start_pos[3]
	local end_line, end_col = end_pos[2], end_pos[3]

	-- Get current buffer
	local buffer = vim.api.nvim_get_current_buf()
	local full_path = vim.api.nvim_buf_get_name(buffer)
	local rel_path = get_relative_path(full_path)

	-- Get selected text
	local selected_text = {}
	if start_line == end_line then
		local lines = vim.api.nvim_buf_get_lines(buffer, start_line - 1, start_line, false)
		if lines and #lines > 0 then
			local line = lines[1]
			if line then
				table.insert(selected_text, line:sub(start_col, end_col))
			end
		end
	else
		-- Get first line (partial)
		local first_lines = vim.api.nvim_buf_get_lines(buffer, start_line - 1, start_line, false)
		if first_lines and #first_lines > 0 and first_lines[1] then
			table.insert(selected_text, first_lines[1]:sub(start_col))
		end

		-- Get middle lines (complete)
		if end_line - start_line > 1 then
			local middle_lines = vim.api.nvim_buf_get_lines(buffer, start_line, end_line - 1, false)
			for _, line in ipairs(middle_lines) do
				if line then
					table.insert(selected_text, line)
				end
			end
		end

		-- Get last line (partial)
		local last_lines = vim.api.nvim_buf_get_lines(buffer, end_line - 1, end_line, false)
		if last_lines and #last_lines > 0 and last_lines[1] then
			table.insert(selected_text, last_lines[1]:sub(1, end_col))
		end
	end

	-- Create header text with location information
	local command_text = "Selection from "
		.. rel_path
		.. " (lines "
		.. start_line
		.. "-"
		.. end_line
		.. "):\n\n```\n"
		.. table.concat(selected_text, "\n")
		.. "\n```\n\n"

	-- Setup UI
	local agent_buf, agent_win = setup_agent_ui()

	-- Update buffer with command text
	update_agent_buffer(agent_buf, command_text)

	-- Focus end of buffer
	focus_end_of_buffer(agent_win, agent_buf)
end, {})

-- Define a custom command to select directories and send them to buffer below Claude Code
vim.api.nvim_create_user_command("ClaudeCodeDirectories", function()
	local telescope = require("telescope.builtin")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	-- Open Telescope directory picker with multi-select
	telescope.find_files({
		attach_mappings = function(prompt_bufnr, map)
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

				-- Setup UI
				local agent_buf, agent_win = setup_agent_ui()

				-- Create command text for all directories
				local command_text = ""
				for _, dir in ipairs(dirs_to_send) do
					local rel_path = get_relative_path(dir)
					command_text = command_text .. "READ " .. rel_path .. "/**/*\n"
				end
				command_text = command_text .. "\n"

				-- Update buffer with command text
				update_agent_buffer(agent_buf, command_text)

				-- Focus end of buffer
				focus_end_of_buffer(agent_win, agent_buf)

				vim.notify("Added " .. #dirs_to_send .. " directories to agent-input buffer", vim.log.levels.INFO)
			end)

			return true
		end,
		find_command = { "find", ".", "-type", "d", "-not", "-path", "*/\\.*" },
		prompt_title = "Select Directories for Claude Code (Tab to select multiple, Enter to confirm)",
	})
end, {})

-- Define a custom command to select multiple files and send them to buffer below Claude Code
vim.api.nvim_create_user_command("ClaudeCodeFiles", function()
	local telescope = require("telescope.builtin")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	-- Open Telescope file picker with multi-select
	telescope.find_files({
		attach_mappings = function(prompt_bufnr, map)
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

				-- Setup UI
				local agent_buf, agent_win = setup_agent_ui()

				-- Create command text for all files
				local command_text = ""
				for _, file in ipairs(files_to_send) do
					local rel_path = get_relative_path(file)
					command_text = command_text .. "READ " .. rel_path .. "\n"
				end
				command_text = command_text .. "\n"

				-- Update buffer with command text
				update_agent_buffer(agent_buf, command_text)

				-- Focus end of buffer
				focus_end_of_buffer(agent_win, agent_buf)

				vim.notify("Added " .. #files_to_send .. " files to agent-input buffer", vim.log.levels.INFO)
			end)

			return true
		end,
		prompt_title = "Select Files for Claude Code (Tab to select multiple, Enter to confirm)",
	})
end, {})

-- Define a custom command to toggle the agent-input buffer
vim.api.nvim_create_user_command("ClaudeCodeInput", function()
	-- Check if the Claude Code buffer exists
	local claude_code = require("claude-code")
	local bufnr = claude_code.claude_code.bufnr

	-- Check if agent-input buffer already exists
	local agent_buf = nil
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(buf):match("agent%-input$") then
			agent_buf = buf
			break
		end
	end

	-- Find agent-input window if it exists
	local agent_win = nil
	if agent_buf and vim.api.nvim_buf_is_valid(agent_buf) then
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if vim.api.nvim_win_get_buf(win) == agent_buf then
				agent_win = win
				break
			end
		end
	end

	-- Find Claude Code window if it exists
	local claude_win = nil
	if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
		local win_ids = vim.fn.win_findbuf(bufnr)
		if #win_ids > 0 then
			claude_win = win_ids[1]
		end
	end

	-- If both windows are visible, hide them (toggle off)
	if agent_win and claude_win then
		-- Store buffer content in a global variable for later restoration
		if agent_buf and vim.api.nvim_buf_is_valid(agent_buf) then
			-- Save buffer content to restore later
			local lines = vim.api.nvim_buf_get_lines(agent_buf, 0, -1, false)
			-- Use vim global variable to persist content between toggles
			vim.g.agent_input_content = lines
		end

		-- Close agent-input window (but don't delete the buffer)
		vim.api.nvim_win_close(agent_win, true)

		-- Close Claude Code
		claude_code.toggle()

		-- No notification when closing
		return
	end

	-- Otherwise, open or ensure they're both visible (toggle on)
	-- Setup UI which will handle creating or focusing Claude and agent windows
	local agent_buffer, agent_window = setup_agent_ui()

	-- Restore saved content if it exists
	if vim.g.agent_input_content then
		vim.api.nvim_buf_set_lines(agent_buffer, 0, -1, false, vim.g.agent_input_content)
		vim.bo[agent_buffer].modified = false
	end

	-- Focus end of buffer
	focus_end_of_buffer(agent_window, agent_buffer)

	-- No notification when opening
end, {})

-- Helper function to scan prompt files from directory
local function scan_prompt_files(dir_path)
	-- Ensure the path has a trailing slash
	if dir_path:sub(-1) ~= "/" then
		dir_path = dir_path .. "/"
	end

	-- Create directory if it doesn't exist
	local handle = io.popen("mkdir -p " .. dir_path)
	if handle then
		handle:close()
	end

	-- Get a list of all .md files in the directory
	local handle = io.popen("ls -1 " .. dir_path .. "*.md 2>/dev/null || echo ''")
	local result = handle:read("*a")
	handle:close()

	-- Split the result into lines
	local files = {}
	for line in result:gmatch("[^\r\n]+") do
		if line ~= "" then
			table.insert(files, line)
		end
	end

	return files
end

-- Define a custom command to select and load prompt templates
vim.api.nvim_create_user_command("ClaudeCodePrompt", function()
	local telescope = require("telescope.builtin")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values

	-- Scan for prompt files
	local prompt_dir = vim.fn.expand("~/.claude/commands/")
	local prompt_files = scan_prompt_files(prompt_dir)

	-- If no prompt files found, show a notification
	if #prompt_files == 0 then
		vim.notify("No prompt templates found in " .. prompt_dir, vim.log.levels.WARN)
		return
	end

	-- Create a list of entries for the finder
	local entries = {}
	for _, file_path in ipairs(prompt_files) do
		-- Extract filename without path and extension
		local filename = file_path:match("([^/]+)%.md$")
		if filename then
			table.insert(entries, {
				display = filename,
				value = file_path,
				ordinal = filename,
			})
		end
	end

	-- Function to read file content for preview
	local function read_file_content(file_path)
		local file = io.open(file_path, "r")
		if not file then
			return "Could not open file: " .. file_path
		end
		local content = file:read("*a")
		file:close()
		return content
	end

	-- Create a custom picker for prompt files with preview
	pickers
		.new({
			layout_strategy = "vertical",
			layout_config = {
				width = 0.7, -- 70% of screen width
				height = 0.8, -- 80% of screen height
				prompt_position = "top",
				preview_height = 0.6, -- 60% of picker height
			},
		}, {
			prompt_title = "Select a prompt template",
			finder = finders.new_table({
				results = entries,
				entry_maker = function(entry)
					return {
						value = entry.value,
						display = entry.display,
						ordinal = entry.ordinal,
						preview_command = function(entry, bufnr)
							-- Read file content
							local content = read_file_content(entry.value)

							-- Set content and filetype for syntax highlighting
							vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))
							vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")
						end,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = conf.file_previewer({}),
			attach_mappings = function(prompt_bufnr, map)
				-- When a selection is made
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)

					if not selection then
						return
					end

					-- Read the selected prompt file content
					local content = read_file_content(selection.value)

					-- Setup agent UI
					local agent_buf, agent_win = setup_agent_ui()

					-- Update buffer with prompt content
					update_agent_buffer(agent_buf, content)

					-- Focus end of buffer
					focus_end_of_buffer(agent_win, agent_buf)

					vim.notify("Loaded prompt: " .. selection.display, vim.log.levels.INFO)
				end)

				return true
			end,
		})
		:find()
end, {})

-- Create autocommand to close agent-input buffer when claude-code buffer is closed
vim.api.nvim_create_autocmd("BufDelete", {
	pattern = "*",
	callback = function(ev)
		-- Check if the deleted buffer was a claude-code buffer
		local bufname = vim.api.nvim_buf_get_name(ev.buf)
		local buftype = vim.bo[ev.buf].buftype
		local filetype = vim.bo[ev.buf].filetype
		
		-- Check if this is a claude-code buffer (terminal with claude-code filetype)
		if buftype == "terminal" and filetype == "claude-code" then
			-- Find and close the agent-input buffer
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_name(buf):match("agent%-input$") then
					-- Save buffer content before closing
					local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
					vim.g.agent_input_content = lines
					
					-- Close all windows associated with this buffer
					local win_ids = vim.fn.win_findbuf(buf)
					for _, win_id in ipairs(win_ids) do
						if vim.api.nvim_win_is_valid(win_id) then
							vim.api.nvim_win_close(win_id, true)
						end
					end
					
					-- Delete the buffer
					vim.api.nvim_buf_delete(buf, { force = true })
					break
				end
			end
		end
	end,
})
