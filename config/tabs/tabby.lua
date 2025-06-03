-- Always show tabline
vim.o.showtabline = 2

-- Set session options to include tabpages
vim.opt.sessionoptions = "curdir,folds,globals,help,tabpages,terminal,winsize"

-- Setup autocmds to update tabline on mode change
vim.api.nvim_create_autocmd({ "ModeChanged", "InsertEnter", "InsertLeave", "CmdlineEnter", "CmdlineLeave" }, {
	callback = function()
		vim.cmd("redrawtabline")
	end,
})

-- Force tabline update more frequently
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI" }, {
	callback = function()
		vim.cmd("silent! redrawtabline")
	end,
})

-- Setup tabby
require("tabby").setup({
	line = function(line)
		local hostname = vim.fn.hostname()
		-- Define separators (these are from tabline.lua)
		local left_sep = ""
		local right_sep = ""
		local in_tmux = os.getenv("TMUX_PANE") ~= nil

		-- Get tmux windows if in tmux session
		local tmux_windows = {}
		if in_tmux then
			local handle = io.popen("tmux list-windows -F '#{window_index} #{window_name} #{window_active}'")
			if handle then
				for line in handle:lines() do
					local index, name, active = line:match("(%d+) ([^%s]+) (%d+)")
					if index then
						table.insert(tmux_windows, {
							index = tonumber(index),
							name = name,
							active = active == "1",
						})
					end
				end
				handle:close()
			end
		end

		-- Create the header section
		local header = {}

		-- Define mode colors
		local mode_colors = {
			["n"] = "TabLine", -- Normal mode
			["i"] = "DiagnosticError", -- Insert mode
			["v"] = "DiagnosticWarn", -- Visual mode
			["V"] = "DiagnosticWarn", -- Visual Line mode
			[""] = "DiagnosticWarn", -- Visual Block mode
			["c"] = "DiagnosticInfo", -- Command mode
			["s"] = "DiagnosticHint", -- Select mode
			["S"] = "DiagnosticHint", -- Select Line mode
			[""] = "DiagnosticHint", -- Select Block mode
			["R"] = "DiagnosticError", -- Replace mode
			["t"] = "Directory", -- Terminal mode
			-- Default for other modes
			["default"] = "TabLine",
		}

		-- Get current mode
		local mode = vim.api.nvim_get_mode().mode
		local mode_hl = mode_colors[mode] or mode_colors["default"]

		-- Always add hostname with mode-based highlighting
		table.insert(header, { "   " .. hostname .. " ", hl = mode_hl })
		table.insert(header, line.sep(right_sep, "TabLine", "TabLineFill"))

		-- Only add the tmux session name if we're in a tmux session
		if in_tmux then
			-- Get tmux session name using tmux display-message
			local handle = io.popen("tmux display-message -p '#S'")
			local session_name = "tmux"
			if handle then
				session_name = handle:read("*a"):gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
				handle:close()
			end
			table.insert(header, line.sep(left_sep, "TabLine", "TabLineFill"))
			table.insert(header, { "   " .. session_name .. " ", hl = "TabLine" })
			table.insert(header, line.sep(right_sep, "TabLine", "TabLineFill"))
		end

		-- Add git branch if available (except default branches)
		local git_branch = ""
		local default_branches = { "main", "master" }
		local git_handle = io.popen("git branch --show-current 2>/dev/null")
		if git_handle then
			git_branch = git_handle:read("*a"):gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
			git_handle:close()

			-- Check if branch should be displayed
			local show_branch = git_branch ~= ""
			for _, branch in ipairs(default_branches) do
				if git_branch == branch then
					show_branch = false
					break
				end
			end

			if show_branch then
				table.insert(header, line.sep(left_sep, "TabLine", "TabLineFill"))
				table.insert(header, { " 󰘬  " .. git_branch .. " ", hl = "TabLine" })
				table.insert(header, line.sep(right_sep, "TabLine", "TabLineFill"))
			end
		end

		-- Get current position info for line:col display
		local line_col_info = {}
		local cur_line = vim.fn.line(".")
		local cur_col = vim.fn.col(".")

		table.insert(line_col_info, line.sep(left_sep, "TabLine", "TabLineFill"))
		table.insert(line_col_info, { " " .. cur_line .. ":" .. cur_col .. " ", hl = "TabLine" })
		table.insert(line_col_info, line.sep(right_sep, "TabLine", "TabLineFill"))

		-- Overseer tasks integration
		local overseer_info = {}
		if package.loaded.overseer then
			local tasks = require("overseer.task_list").list_tasks({ unique = true })
			local tasks_by_status = require("overseer.util").tbl_group_by(tasks, "status")

			-- Define status symbols (using Nerd Font icons)
			local symbols = {
				["CANCELED"] = " ",
				["FAILURE"] = "󰅚 ",
				["SUCCESS"] = "󰄴 ",
				["RUNNING"] = "󰑮 ",
			}

			-- Add tasks for each status if they exist
			for _, status in ipairs({ "RUNNING", "SUCCESS", "FAILURE", "CANCELED" }) do
				if tasks_by_status[status] and #tasks_by_status[status] > 0 then
					table.insert(overseer_info, line.sep(left_sep, "TabLine", "TabLineFill"))
					local hl = "Overseer" .. status
					-- Fallback to TabLine if highlight doesn't exist
					if not pcall(vim.api.nvim_get_hl_id_by_name, hl) then
						hl = "TabLine"
					end
					table.insert(overseer_info, {
						symbols[status] .. #tasks_by_status[status] .. " ",
						hl = hl,
					})
					table.insert(overseer_info, line.sep(right_sep, "TabLine", "TabLineFill"))
				end
			end
		end

		return {
			header,
			line_col_info,
			overseer_info, -- Added overseer info here, right after line_col_info
			hl = "TabLineFill",
			line.spacer(),
			line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
				-- Check if buffer is modified
				local buf_id = win.buf().id
				local modified = vim.bo[buf_id].modified
				local modified_indicator = modified and " " or ""

				return {
					line.sep(left_sep, "TabLine", "TabLineFill"),
					win.is_current() and "" or "",
					modified_indicator .. win.buf_name(),
					line.sep(right_sep, "TabLine", "TabLineFill"),
					hl = "TabLine",
					margin = " ",
				}
			end),
			-- Show regular vim tabs only if more than one exists
			vim.fn.tabpagenr("$") > 1
					and line.tabs().foreach(function(tab)
						local hl = tab.is_current() and "TabLineSel" or "TabLine"
						-- Always start with an empty tab name
						local tab_display_name = ""

						-- Display jump key if in jump mode, otherwise tab number
						local tab_indicator = tab.in_jump_mode() and tab.jump_key() or tab.number()

						return {
							line.sep(left_sep, hl, "TabLineFill"),
							tab.is_current() and " " or " ",
							tab_indicator,
							tab_display_name,
							tab.close_btn(""),
							line.sep(right_sep, hl, "TabLineFill"),
							hl = hl,
							margin = " ",
						}
					end)
				or {},
			-- Show tmux windows as tabs if in tmux (hide if only 1 window named main/master)
			in_tmux
					and (#tmux_windows > 1 or (#tmux_windows == 1 and tmux_windows[1].name ~= "main" and tmux_windows[1].name ~= "master"))
					and vim.tbl_map(function(window)
						local hl = window.active and "TabLineSel" or "TabLine"
						local indicator = window.active and " " or "󰘬 "
						return {
							line.sep(left_sep, hl, "TabLineFill"),
							" " .. indicator .. " " .. window.name,
							line.sep(right_sep, hl, "TabLineFill"),
							hl = hl,
							margin = " ",
						}
					end, tmux_windows)
				or {},
		}
	end,
})

-- Function to create a picker for tmux windows and vim tabs
local function tab_picker()
	local items = {}
	local in_tmux = os.getenv("TMUX_PANE") ~= nil

	-- Get git worktrees
	local worktrees = {}
	local git_handle = io.popen("git worktree list 2>/dev/null")
	if git_handle then
		for line in git_handle:lines() do
			local path, branch = line:match("([^%s]+)%s+[^%s]+%s+%[([^%]]+)%]")
			if path and branch and not line:match("%(bare%)") then
				local worktree_name = branch
				worktrees[worktree_name] = {
					name = worktree_name,
					path = path,
					branch = branch,
				}
			end
		end
		git_handle:close()
	end

	-- Get tmux windows and match with worktrees
	local tmux_windows = {}
	local matched_worktrees = {}
	if in_tmux then
		local handle = io.popen("tmux list-windows -F '#{window_index} #{window_name} #{window_active}'")
		if handle then
			for line in handle:lines() do
				local index, name, active = line:match("(%d+) ([^%s]+) (%d+)")
				if index then
					tmux_windows[name] = {
						index = tonumber(index),
						name = name,
						active = active == "1",
					}

					-- If this tmux window matches a worktree, mark it as matched
					if worktrees[name] then
						matched_worktrees[name] = true
					end
				end
			end
			handle:close()
		end
	end

	-- Add vim tabs (skip current tab)
	for i = 1, vim.fn.tabpagenr("$") do
		if i ~= vim.fn.tabpagenr() then
			local tab_info = {
				type = "vim_tab",
				index = i,
				name = "Tab " .. i,
				current = false,
			}
			table.insert(items, {
				text = "  Tab " .. i,
				value = tab_info,
			})
		end
	end

	-- Add tmux windows if in tmux (skip active window, skip those matched with worktrees)
	if in_tmux then
		for name, window in pairs(tmux_windows) do
			if not window.active and not matched_worktrees[name] then
				table.insert(items, {
					text = "  " .. name .. " (tmux)",
					value = {
						type = "tmux_window",
						index = window.index,
						name = name,
						current = false,
					},
				})
			end
		end
	end

	-- Add worktrees
	for name, worktree in pairs(worktrees) do
		local tmux_window = tmux_windows[name]
		if tmux_window and not tmux_window.active then
			-- Worktree has corresponding tmux window (show as open)
			table.insert(items, {
				text = " ● " .. name,
				value = {
					type = "worktree_open",
					name = name,
					tmux_index = tmux_window.index,
					path = worktree.path,
				},
			})
		elseif not tmux_window then
			-- Worktree has no tmux window (show as available to open)
			table.insert(items, {
				text = "  " .. name .. " (worktree)",
				value = {
					type = "worktree_new",
					name = name,
					path = worktree.path,
				},
			})
		end
	end

	-- Use vim.ui.select for the picker
	vim.ui.select(items, {
		prompt = "Select tab/window:",
		format_item = function(item)
			return item.text
		end,
	}, function(choice)
		if not choice then
			return
		end

		local info = choice.value
		if info.type == "vim_tab" then
			vim.cmd("tabnext " .. info.index)
		elseif info.type == "tmux_window" then
			vim.fn.system("tmux select-window -t " .. info.index)
		elseif info.type == "worktree_open" then
			-- Switch to existing tmux window
			vim.fn.system("tmux select-window -t " .. info.tmux_index)
		elseif info.type == "worktree_new" then
			-- Create new tmux window and start neovim in worktree directory
			local cmd = string.format("tmux new-window -n '%s' -c '%s' 'nvim'", info.name, info.path)
			vim.fn.system(cmd)
		end
	end)
end

-- Create command and keymap for the tab picker
vim.api.nvim_create_user_command("TabPicker", tab_picker, {})
vim.keymap.set("n", "<leader>tp", tab_picker, { desc = "Open tab/window picker" })
