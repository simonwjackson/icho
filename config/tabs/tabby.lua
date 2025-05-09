-- Always show tabline
vim.o.showtabline = 2

-- Set session options to include tabpages
vim.opt.sessionoptions = "curdir,folds,globals,help,tabpages,terminal,winsize"

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

		-- Always add hostname
		table.insert(header, { "   " .. hostname .. " ", hl = "TabLine" })
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

		return {
			header,
			line.tabs().foreach(function(tab)
				local hl = tab.is_current() and "TabLineSel" or "TabLine"
				-- Use a custom method to display the tab name without [1+]
				local tab_display_name = tab.name() or ""
				-- Remove the [n+] pattern if it exists
				tab_display_name = tab_display_name:gsub("%[%d+%+?%]", "")

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
			hl = "TabLineFill",
		}
	end,
})

