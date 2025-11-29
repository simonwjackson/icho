-- Resession
local resession = require("resession")

-- Function to get the appropriate session directory
local function get_session_dir()
	-- First, try to get git root
	local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")

	if vim.v.shell_error ~= 0 then
		-- Not in a git repo, use current directory
		return vim.fn.getcwd()
	end

	-- Check if we're in a git worktree
	local git_dir = vim.fn.system("git rev-parse --git-dir 2>/dev/null"):gsub("\n", "")

	if vim.v.shell_error == 0 and git_dir:match("%.git/worktrees/") then
		-- We're in a worktree, use the worktree directory (which includes branch name)
		local worktree_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
		return worktree_root
	end

	-- Regular git repo, use git root
	return git_root
end

-- Get full path to session file
local function get_session_file()
	return get_session_dir() .. "/.resession.json"
end

resession.setup({
	-- Disable autosave since we'll handle it manually
	autosave = {
		enabled = false,
	},
	-- Your other preferred options
	buf_filter = resession.default_buf_filter,
	extensions = {
		quickfix = {},
	},
})

-- Helper function to convert paths in window layouts
local function convert_winlayout_paths(layout, base_dir, to_relative)
	if type(layout) ~= "table" then
		return layout
	end

	-- Handle leaf nodes
	if layout[1] == "leaf" and layout[2] and layout[2].bufname then
		if to_relative then
			-- Convert to relative
			if vim.startswith(layout[2].bufname, base_dir) then
				layout[2].bufname = layout[2].bufname:sub(#base_dir + 2)
			end
		else
			-- Convert to absolute
			if not vim.startswith(layout[2].bufname, "/") and not vim.startswith(layout[2].bufname, "~") then
				layout[2].bufname = base_dir .. "/" .. layout[2].bufname
			end
		end
	-- Handle row/col nodes (recursive)
	elseif (layout[1] == "row" or layout[1] == "col") and layout[2] then
		for _, child in ipairs(layout[2]) do
			convert_winlayout_paths(child, base_dir, to_relative)
		end
	end

	return layout
end

-- Convert absolute paths to relative paths
local function make_paths_relative(content, base_dir)
	-- Parse JSON
	local data = vim.json.decode(content)

	-- Convert buffer paths to relative
	if data.buffers then
		for _, buffer in ipairs(data.buffers) do
			if buffer.name and buffer.name ~= "" then
				-- Check if path is within project directory
				if vim.startswith(buffer.name, base_dir) then
					-- Make relative by removing base_dir and leading slash
					buffer.name = buffer.name:sub(#base_dir + 2)
				end
			end
		end
	end

	-- Convert cwd paths to relative
	if data.global and data.global.cwd then
		if vim.startswith(data.global.cwd, base_dir) then
			data.global.cwd = "."
		end
	end

	-- Convert tab paths and window layouts
	if data.tabs then
		for _, tab in ipairs(data.tabs) do
			if tab.cwd and vim.startswith(tab.cwd, base_dir) then
				tab.cwd = "."
			end
			-- Convert paths in window layouts
			if tab.wins then
				convert_winlayout_paths(tab.wins, base_dir, true)
			end
		end
	end

	return vim.json.encode(data)
end

-- Custom save function that saves to project root
local function save_to_project_root()
	-- First save using resession's normal mechanism
	resession.save("temp_session", { notify = false, attach = false })

	-- Then copy the session file to project root
	local session_file = vim.fn.stdpath("data") .. "/session/temp_session.json"
	local target_file = get_session_file()
	local base_dir = get_session_dir()

	-- Read the session file
	local file = io.open(session_file, "r")
	if file then
		local content = file:read("*all")
		file:close()

		-- Convert paths to relative
		content = make_paths_relative(content, base_dir)

		-- Write to project root
		local target = io.open(target_file, "w")
		if target then
			target:write(content)
			target:close()
		end

		-- Clean up temp file
		os.remove(session_file)
	end
end

-- Convert relative paths to absolute paths
local function make_paths_absolute(content, base_dir)
	-- Parse JSON
	local data = vim.json.decode(content)

	-- Convert buffer paths to absolute
	if data.buffers then
		for _, buffer in ipairs(data.buffers) do
			if buffer.name and buffer.name ~= "" then
				-- Check if path is relative (doesn't start with /)
				if not vim.startswith(buffer.name, "/") and not vim.startswith(buffer.name, "~") then
					buffer.name = base_dir .. "/" .. buffer.name
				end
			end
		end
	end

	-- Convert cwd paths to absolute
	if data.global and data.global.cwd and data.global.cwd == "." then
		data.global.cwd = base_dir
	end

	-- Convert tab paths and window layouts
	if data.tabs then
		for _, tab in ipairs(data.tabs) do
			if tab.cwd and tab.cwd == "." then
				tab.cwd = base_dir
			end
			-- Convert paths in window layouts
			if tab.wins then
				convert_winlayout_paths(tab.wins, base_dir, false)
			end
		end
	end

	return vim.json.encode(data)
end

-- Custom load function that loads from project root
local function load_from_project_root()
	local session_file = get_session_file()
	local base_dir = get_session_dir()

	-- Check if session file exists
	local file = io.open(session_file, "r")
	if not file then
		return false
	end
	file:close()

	-- Copy to temp location
	local temp_session = vim.fn.stdpath("data") .. "/session/temp_session.json"

	-- Ensure session directory exists
	vim.fn.mkdir(vim.fn.stdpath("data") .. "/session", "p")

	-- Read and convert file
	local source = io.open(session_file, "r")
	if source then
		local content = source:read("*all")
		source:close()

		-- Convert relative paths to absolute
		content = make_paths_absolute(content, base_dir)

		local target = io.open(temp_session, "w")
		if target then
			target:write(content)
			target:close()

			-- Load the session
			resession.load("temp_session", { silence_errors = true })

			-- Clean up temp file
			os.remove(temp_session)
			return true
		end
	end
	return false
end

-- Auto-save on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
	group = vim.api.nvim_create_augroup("ResessionAutoSave", { clear = true }),
	callback = function()
		save_to_project_root()
	end,
})

-- Auto-load session on startup if no files were specified
vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("ResessionAutoLoad", { clear = true }),
	callback = function()
		-- Only auto-load if Neovim was started with no arguments
		if vim.fn.argc(-1) == 0 then
			load_from_project_root()
		end
	end,
	nested = true,
})

-- =====================================================
-- Claude Instances Persistence Extension
-- =====================================================

-- File to store claude instances metadata (alongside .resession.json)
local function get_claude_instances_file()
	return get_session_dir() .. "/.claude-instances.json"
end

-- Save claude instances metadata before session save
vim.api.nvim_create_autocmd("User", {
	pattern = "ResessionSavePre",
	callback = function()
		-- Check if we have any claude instances
		if not _G.claude_instances_registry then
			return
		end

		local instances_data = {}
		for id, data in pairs(_G.claude_instances_registry) do
			-- Only save metadata, not the terminal object
			table.insert(instances_data, {
				id = id,
				cwd = data.cwd,
				args = data.args or "",
			})
		end

		if #instances_data > 0 then
			local file = io.open(get_claude_instances_file(), "w")
			if file then
				file:write(vim.json.encode(instances_data))
				file:close()
			end
		else
			-- Remove file if no instances
			os.remove(get_claude_instances_file())
		end
	end,
})

-- Also save on VimLeavePre (before the main session save)
vim.api.nvim_create_autocmd("VimLeavePre", {
	group = vim.api.nvim_create_augroup("ClaudeInstancesSave", { clear = true }),
	callback = function()
		if not _G.claude_instances_registry then
			return
		end

		local instances_data = {}
		for id, data in pairs(_G.claude_instances_registry) do
			table.insert(instances_data, {
				id = id,
				cwd = data.cwd,
				args = data.args or "",
			})
		end

		if #instances_data > 0 then
			local file = io.open(get_claude_instances_file(), "w")
			if file then
				file:write(vim.json.encode(instances_data))
				file:close()
			end
		else
			os.remove(get_claude_instances_file())
		end
	end,
})

-- Restore claude instances after session load
vim.api.nvim_create_autocmd("User", {
	pattern = "ResessionLoadPost",
	callback = function()
		-- Wait for toggleterm to be initialized
		vim.defer_fn(function()
			if not _G.claude_spawn_instance then
				return
			end

			local file = io.open(get_claude_instances_file(), "r")
			if not file then
				return
			end

			local content = file:read("*all")
			file:close()

			local ok, instances_data = pcall(vim.json.decode, content)
			if not ok or type(instances_data) ~= "table" then
				return
			end

			-- Restore each instance
			for _, inst in ipairs(instances_data) do
				_G.claude_spawn_instance({
					id = inst.id,
					cwd = inst.cwd,
					args = inst.args,
				})
				-- Close immediately so they're available but not in the way
				vim.defer_fn(function()
					if _G.claude_instances_registry and _G.claude_instances_registry[inst.id] then
						_G.claude_instances_registry[inst.id].terminal:close()
					end
				end, 100)
			end

			vim.notify("Restored " .. #instances_data .. " Claude instance(s)", vim.log.levels.INFO)
		end, 500)
	end,
})
