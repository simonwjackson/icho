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

		return {
			header,
			line_col_info,
			hl = "TabLineFill",
			line.spacer(),
			line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
				return {
					line.sep(left_sep, "TabLine", "TabLineFill"),
					win.is_current() and "" or "",
					win.buf_name(),
					line.sep(right_sep, "TabLine", "TabLineFill"),
					hl = "TabLine",
					margin = " ",
				}
			end),
			line.tabs().foreach(function(tab)
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
			end),
		}
	end,
})

