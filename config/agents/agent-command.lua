-- Define a custom command to send the current file to a buffer below Claude Code
vim.api.nvim_create_user_command("ClaudeCodeFile", function()
	-- Get the current buffer name
	local buffer = vim.api.nvim_get_current_buf()
	local full_path = vim.api.nvim_buf_get_name(buffer)
	local cwd = vim.fn.getcwd()
	local rel_path = full_path

	-- Try to get relative path if file is under cwd
	if full_path:sub(1, #cwd) == cwd then
		rel_path = full_path:sub(#cwd + 2) -- +2 to skip the slash after cwd
	end

	-- Check if the Claude Code buffer exists
	local claude_code = require("claude-code")
	local bufnr = claude_code.claude_code.bufnr

	-- Open Claude Code if not already open
	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
		claude_code.toggle()
		bufnr = claude_code.claude_code.bufnr
	else
		-- Find Claude window and focus it
		local win_ids = vim.fn.win_findbuf(bufnr)
		if #win_ids > 0 then
			vim.api.nvim_set_current_win(win_ids[1])
		else
			-- Open Claude Code window if not visible
			claude_code.toggle()
		end
	end

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

	-- Find agent-input window if it exists
	local agent_win = nil
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == agent_buf then
			agent_win = win
			break
		end
	end

	-- Create new window below Claude if agent window doesn't exist
	if not agent_win then
		-- Split below current Claude window
		vim.cmd("split")
		vim.cmd("wincmd j") -- Move to the split window

		-- Set the buffer in the new window
		agent_win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(agent_win, agent_buf)

		-- Resize the window to a reasonable height
		vim.api.nvim_win_set_height(agent_win, 10)
	else
		-- Focus the existing agent window
		vim.api.nvim_set_current_win(agent_win)
	end

	-- Read file content
	local file = io.open(full_path, "r")
	if file then
		file:close()
	end

	-- Create command text and update buffer
	local command_text = "READ " .. rel_path .. "\n\n"

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
		vim.api.nvim_buf_set_lines(agent_buf, end_line, end_line, false, vim.split(command_text, "\n"))
	else
		-- Clear buffer and set the command text at the start (initial case)
		vim.api.nvim_buf_set_lines(agent_buf, 0, -1, false, vim.split(command_text, "\n"))
	end

	-- Mark the buffer as not modified to prevent "unsaved changes" prompts
	vim.bo[agent_buf].modified = false

	-- Move cursor to the end of the appended command
	local last_line = vim.api.nvim_buf_line_count(agent_buf)
	vim.api.nvim_win_set_cursor(agent_win, { last_line, 0 })
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

	-- Get Claude Code buffer
	local claude_code = require("claude-code")
	local bufnr = claude_code.claude_code.bufnr

	-- Check if Claude Code buffer exists
	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
		claude_code.toggle()
		bufnr = claude_code.claude_code.bufnr
	end

	-- Get full content from agent-input buffer
	local full_content = table.concat(content, "\n")

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

			-- Check if "-- INSERT --" or "MCP server failed to connect" appears in the terminal
			if term_text:match("-- INSERT --") or term_text:match("MCP server failed to connect") then
				in_insert_mode = true
			end

			-- If not in insert mode, send 'i' to enter it
			if not in_insert_mode then
				vim.fn.chansend(term_channel, "i")
				-- Small delay to ensure mode change
				vim.cmd("sleep 10m")
			end

			-- Then send the content
			vim.fn.chansend(term_channel, full_content .. "\n")

			-- Restore original window focus
			vim.api.nvim_set_current_win(current_win)
		else
			-- Fallback: Use feedkeys
			vim.cmd("startinsert")
			vim.api.nvim_put(vim.split(full_content, "\n"), "", true, true)
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", true)
		end
	end

	-- Close agent-input window and buffer
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == agent_buf then
			vim.api.nvim_win_close(win, true)
			break
		end
	end

	-- Delete the agent-input buffer
	vim.api.nvim_buf_delete(agent_buf, { force = true })
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
	local cwd = vim.fn.getcwd()
	local rel_path = full_path

	-- Try to get relative path if file is under cwd
	if full_path:sub(1, #cwd) == cwd then
		rel_path = full_path:sub(#cwd + 2) -- +2 to skip the slash after cwd
	end

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

	-- Check if the Claude Code buffer exists
	local claude_code = require("claude-code")
	local bufnr = claude_code.claude_code.bufnr

	-- Open Claude Code if not already open
	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
		claude_code.toggle()
		bufnr = claude_code.claude_code.bufnr
	else
		-- Find Claude window and focus it
		local win_ids = vim.fn.win_findbuf(bufnr)
		if #win_ids > 0 then
			vim.api.nvim_set_current_win(win_ids[1])
		else
			-- Open Claude Code window if not visible
			claude_code.toggle()
		end
	end

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

	-- Find agent-input window if it exists
	local agent_win = nil
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == agent_buf then
			agent_win = win
			break
		end
	end

	-- Create new window below Claude if agent window doesn't exist
	if not agent_win then
		-- Split below current Claude window
		vim.cmd("split")
		vim.cmd("wincmd j") -- Move to the split window

		-- Set the buffer in the new window
		agent_win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(agent_win, agent_buf)

		-- Resize the window to a reasonable height
		vim.api.nvim_win_set_height(agent_win, 10)
	else
		-- Focus the existing agent window
		vim.api.nvim_set_current_win(agent_win)
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

	-- If buffer is not empty, append to it; otherwise set the initial content
	if vim.api.nvim_buf_line_count(agent_buf) > 1 then
		-- Append command text to the end of the buffer
		local end_line_buf = vim.api.nvim_buf_line_count(agent_buf)
		-- Add a separator line if the buffer doesn't end with empty lines
		local last_line = vim.api.nvim_buf_get_lines(agent_buf, end_line_buf - 1, end_line_buf, false)[1]
		if last_line and last_line ~= "" then
			vim.api.nvim_buf_set_lines(agent_buf, end_line_buf, end_line_buf, false, { "" })
			end_line_buf = end_line_buf + 1
		end
		vim.api.nvim_buf_set_lines(agent_buf, end_line_buf, end_line_buf, false, vim.split(command_text, "\n"))
	else
		-- Clear buffer and set the command text at the start (initial case)
		vim.api.nvim_buf_set_lines(agent_buf, 0, -1, false, vim.split(command_text, "\n"))
	end

	-- Mark the buffer as not modified to prevent "unsaved changes" prompts
	vim.bo[agent_buf].modified = false

	-- Move cursor to the end of the appended command
	local last_line = vim.api.nvim_buf_line_count(agent_buf)
	vim.api.nvim_win_set_cursor(agent_win, { last_line, 0 })
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

				-- Check if the Claude Code buffer exists
				local claude_code = require("claude-code")
				local bufnr = claude_code.claude_code.bufnr

				-- Open Claude Code if not already open
				if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
					claude_code.toggle()
					bufnr = claude_code.claude_code.bufnr
				else
					-- Find Claude window and focus it
					local win_ids = vim.fn.win_findbuf(bufnr)
					if #win_ids > 0 then
						vim.api.nvim_set_current_win(win_ids[1])
					else
						-- Open Claude Code window if not visible
						claude_code.toggle()
					end
				end

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

				-- Find agent-input window if it exists
				local agent_win = nil
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					if vim.api.nvim_win_get_buf(win) == agent_buf then
						agent_win = win
						break
					end
				end

				-- Create new window below Claude if agent window doesn't exist
				if not agent_win then
					-- Split below current Claude window
					vim.cmd("split")
					vim.cmd("wincmd j") -- Move to the split window

					-- Set the buffer in the new window
					agent_win = vim.api.nvim_get_current_win()
					vim.api.nvim_win_set_buf(agent_win, agent_buf)

					-- Resize the window to a reasonable height
					vim.api.nvim_win_set_height(agent_win, 10)
				else
					-- Focus the existing agent window
					vim.api.nvim_set_current_win(agent_win)
				end

				-- Create command text for all directories
				local command_text = ""
				for _, dir in ipairs(dirs_to_send) do
					local cwd = vim.fn.getcwd()
					local rel_path = dir
					-- Try to get relative path if directory is under cwd
					if dir:sub(1, #cwd) == cwd then
						rel_path = dir:sub(#cwd + 2) -- +2 to skip the slash after cwd
					end
					command_text = command_text .. "READ " .. rel_path .. "/**/*\n"
				end
				command_text = command_text .. "\n"

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
					vim.api.nvim_buf_set_lines(agent_buf, end_line, end_line, false, vim.split(command_text, "\n"))
				else
					-- Clear buffer and set the command text at the start (initial case)
					vim.api.nvim_buf_set_lines(agent_buf, 0, -1, false, vim.split(command_text, "\n"))
				end

				-- Mark the buffer as not modified to prevent "unsaved changes" prompts
				vim.bo[agent_buf].modified = false

				-- Move cursor to the end of the appended command
				local last_line = vim.api.nvim_buf_line_count(agent_buf)
				vim.api.nvim_win_set_cursor(agent_win, { last_line, 0 })

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

				-- Check if the Claude Code buffer exists
				local claude_code = require("claude-code")
				local bufnr = claude_code.claude_code.bufnr

				-- Open Claude Code if not already open
				if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
					claude_code.toggle()
					bufnr = claude_code.claude_code.bufnr
				else
					-- Find Claude window and focus it
					local win_ids = vim.fn.win_findbuf(bufnr)
					if #win_ids > 0 then
						vim.api.nvim_set_current_win(win_ids[1])
					else
						-- Open Claude Code window if not visible
						claude_code.toggle()
					end
				end

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

				-- Find agent-input window if it exists
				local agent_win = nil
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					if vim.api.nvim_win_get_buf(win) == agent_buf then
						agent_win = win
						break
					end
				end

				-- Create new window below Claude if agent window doesn't exist
				if not agent_win then
					-- Split below current Claude window
					vim.cmd("split")
					vim.cmd("wincmd j") -- Move to the split window

					-- Set the buffer in the new window
					agent_win = vim.api.nvim_get_current_win()
					vim.api.nvim_win_set_buf(agent_win, agent_buf)

					-- Resize the window to a reasonable height
					vim.api.nvim_win_set_height(agent_win, 10)
				else
					-- Focus the existing agent window
					vim.api.nvim_set_current_win(agent_win)
				end

				-- Create command text for all files
				local command_text = ""
				for _, file in ipairs(files_to_send) do
					local cwd = vim.fn.getcwd()
					local rel_path = file
					-- Try to get relative path if file is under cwd
					if file:sub(1, #cwd) == cwd then
						rel_path = file:sub(#cwd + 2) -- +2 to skip the slash after cwd
					end
					command_text = command_text .. "READ " .. rel_path .. "\n"
				end
				command_text = command_text .. "\n"

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
					vim.api.nvim_buf_set_lines(agent_buf, end_line, end_line, false, vim.split(command_text, "\n"))
				else
					-- Clear buffer and set the command text at the start (initial case)
					vim.api.nvim_buf_set_lines(agent_buf, 0, -1, false, vim.split(command_text, "\n"))
				end

				-- Mark the buffer as not modified to prevent "unsaved changes" prompts
				vim.bo[agent_buf].modified = false

				-- Move cursor to the end of the appended command
				local last_line = vim.api.nvim_buf_line_count(agent_buf)
				vim.api.nvim_win_set_cursor(agent_win, { last_line, 0 })

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

	-- If both windows are visible, close them (toggle off)
	if agent_win and claude_win then
		-- Close agent-input window
		vim.api.nvim_win_close(agent_win, true)
		
		-- Remove buffer
		if agent_buf and vim.api.nvim_buf_is_valid(agent_buf) then
			vim.api.nvim_buf_delete(agent_buf, { force = true })
		end
		
		-- Close Claude Code
		claude_code.toggle()
		
		-- No notification when closing
		return
	end

	-- Otherwise, open or ensure they're both visible (toggle on)
	
	-- Open Claude Code if not already open
	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
		claude_code.toggle()
		bufnr = claude_code.claude_code.bufnr
	else
		-- Find Claude window and focus it
		local win_ids = vim.fn.win_findbuf(bufnr)
		if #win_ids > 0 then
			vim.api.nvim_set_current_win(win_ids[1])
		else
			-- Open Claude Code window if not visible
			claude_code.toggle()
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

	-- Find or create agent-input window
	if not agent_win then
		-- Split below current Claude window
		vim.cmd("split")
		vim.cmd("wincmd j") -- Move to the split window

		-- Set the buffer in the new window
		agent_win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(agent_win, agent_buf)

		-- Resize the window to a reasonable height
		vim.api.nvim_win_set_height(agent_win, 10)
	else
		-- Focus the existing agent window
		vim.api.nvim_set_current_win(agent_win)
	end

	-- Move cursor to the end of the buffer
	local last_line = vim.api.nvim_buf_line_count(agent_buf)
	vim.api.nvim_win_set_cursor(agent_win, { last_line, 0 })
	
	-- No notification when opening
end, {})
