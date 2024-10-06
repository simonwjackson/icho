-- This is a lua version of vim which key that displays available keybindings in popup menu.

--     wk.register({
--       mode = { "n", "v" },
--       ["g"] = { name = "+goto" },
--       ["]"] = { name = "+next" },
--       ["["] = { name = "+prev" },
--       ["<leader><tab>"] = { name = "+tabs" },
--       ["<leader>b"] = { name = "+buffer" },
--       ["<leader>c"] = { name = "+code" },
--       ["<leader>f"] = { name = "+file/find" },
--       ["<leader>g"] = { name = "+git" },
--       ["<leader>gh"] = { name = "+hunks" },
--       ["<leader>q"] = { name = "+quit/session" },
--       ["<leader>s"] = { name = "+search" },
--       ["<leader>sn"] = { name = "+noice" },
--       ["<leader>u"] = { name = "+ui" },
--       ["<leader>w"] = { name = "+windows" },
--       ["<leader>x"] = { name = "+diagnostics/quickfix" },
--     })

local cmd = vim.api.nvim_command

return {
	{
		name = "WhichKey",
		dir = "@whichKey@",
		event = "VeryLazy",
		keys = {
			{ "<leader>d", ":quit<cr>", desc = "Close buffer" },
			{ "<Esc>", ":noh <CR>", desc = "Clear highlights" },
			{ "<C-s>", ":update <CR>", desc = "Update file" },
			{
				"<A-s>",
				[[<C-\><C-n>:silent! !tmux choose-tree<cr>]],
				desc = "show tmux sessions",
				nowait = true,
				mode = { "t", "n" },
			},
		},
		opts = {
			plugins = {
				marks = true, -- shows a list of your marks on ' and `
				registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
				-- the presets plugin, adds help for a bunch of default keybindings in Neovim
				-- No actual key bindings are created
				spelling = {
					enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
					suggestions = 20, -- how many suggestions should be shown in the list?
				},
				presets = {
					operators = true, -- adds help for operators like d, y, ...
					motions = true, -- adds help for motions
					text_objects = true, -- help for text objects triggered after entering an operator
					windows = true, -- default bindings on <c-w>
					nav = true, -- misc bindings to work with windows
					z = true, -- bindings for folds, spelling and others prefixed with z
					g = true, -- bindings for prefixed with g
				},
			},
			-- add operators that will trigger motion and text object completion
			-- to enable all native operators, set the preset / operators plugin above
			operators = { gc = "Comments" },
			key_labels = {
				-- override the label used to display some keys. It doesn't effect WK in any other way.
				-- For example:
				["<space>"] = "SPC",
				["<cr>"] = "RET",
				["<tab>"] = "TAB",
			},
			motions = {
				count = true,
			},
			icons = {
				breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
				separator = "➜", -- symbol used between a key and it's label
				group = "+", -- symbol prepended to a group
			},
			preset = "modern",
			ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
			hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "^:", "^ ", "^call ", "^lua " }, -- hide mapping boilerplate
			show_help = true, -- show a help message in the command line for using WhichKey
			show_keys = true, -- show the currently pressed key and its label as a message in the command line
			triggers = "auto", -- automatically setup triggers
			-- triggers = {"<leader>"} -- or specifiy a list manually
			-- list of triggers, where WhichKey should not wait for timeoutlen and show immediately
			triggers_nowait = {
				-- marks
				"`",
				"'",
				"g`",
				"g'",
				-- registers
				'"',
				"<c-r>",
				-- spelling
				"z=",
			},
			triggers_blacklist = {
				-- list of mode / prefixes that should never be hooked by WhichKey
				-- this is mostly relevant for keymaps that start with a native binding
				i = { "j", "k" },
				v = { "j", "k" },
			},
			-- disable the WhichKey popup for certain buf types and file types.
			-- Disabled by default for Telescope
			disable = {
				buftypes = {},
				filetypes = {},
			},
		},
		init = function()
			local wk = require("which-key")

			vim.o.timeout = true
			vim.o.timeoutlen = 100

			wk.add({
				{ "<leader>w", proxy = "<c-w>", group = "windows" }, -- proxy to window mappings
			})
			-- local wk = require("which-key")
			--   { "<leader>w", proxy = "<c-w>", group = "windows" }, -- proxy to window mappings
			--
			-- local function my_lazygit()
			-- 	cmd("tabnew")
			-- 	cmd("LualineRenameTab LazyGit")
			-- 	cmd("terminal nvr -c 'terminal lazygit' -c 'startinsert' '+let g:auto_session_enabled = v:false'")
			-- end
			--
			-- wk.register({
			-- 	["<A-s>"] = {
			-- 		"<C-\\><C-n>:silent! !tmux choose-tree<cr>",
			-- 		"show tmux sessions",
			-- 		opts = { nowait = true },
			-- 	},
			-- }, { mode = "t" })
			--
			-- wk.register({
			-- 	["<leader>gg"] = { my_lazygit, "Open lazygit", opts = { nowait = true } },
			-- 	["<A-s>"] = { ":silent! !tmux choose-tree<cr>", "show tmux sessions", opts = { nowait = true } },
			-- -- See `<cmd> :help vim.lsp.*` for documentation on any of the below functions
			--
			-- wk.register({
			-- 	["gD"] = {
			-- 		function()
			-- 			vim.lsp.buf.declaration()
			-- 		end,
			-- 		"LSP declaration",
			-- 	},
			--
			-- 	["gd"] = {
			-- 		function()
			-- 			vim.lsp.buf.definition()
			-- 		end,
			-- 		"LSP definition",
			-- 	},
			--

			--
			-- 	-- ["gi"] = {
			-- 	--   function()
			-- 	--     vim.lsp.buf.implementation()
			-- 	--   end,
			-- 	--   "LSP implementation",
			-- 	-- },
			-- 	--
			-- 	-- ["<leader>ls"] = {
			-- 	--   function()
			-- 	--     vim.lsp.buf.signature_help()
			-- 	--   end,
			-- 	--   "LSP signature help",
			-- 	-- },
			-- 	--
			-- 	-- ["<leader>D"] = {
			-- 	--   function()
			-- 	--     vim.lsp.buf.type_definition()
			-- 	--   end,
			-- 	--   "LSP definition type",
			-- 	-- },
			-- 	--
			-- 	-- ["<leader>ra"] = {
			-- 	--   function()
			-- 	--     require("nvchad_ui.renamer").open()
			-- 	--   end,
			-- 	--   "LSP rename",
			-- 	-- },
			-- 	--

			-- 	--
			-- 	-- ["gr"] = {
			-- 	--   function()
			-- 	--     vim.lsp.buf.references()
			-- 	--   end,
			-- 	--   "LSP references",
			-- 	-- },
			-- 	--
			-- 	-- ["<leader>f"] = {
			-- 	--   function()
			-- 	--     vim.diagnostic.open_float({ border = "rounded" })
			-- 	--   end,
			-- 	--   "Floating diagnostic",
			-- 	-- },
			-- 	--
			-- 	["[d"] = {
			-- 		function()
			-- 			vim.diagnostic.goto_prev({ float = { border = "rounded" } })
			-- 		end,
			-- 		"Goto prev",
			-- 	},
			--
			-- 	["]d"] = {
			-- 		function()
			-- 			vim.diagnostic.goto_next({ float = { border = "rounded" } })
			-- 		end,
			-- 		"Goto next",
			-- 	},
			--
			-- 	["<leader>q"] = {
			-- 		function()
			-- 			vim.diagnostic.setloclist()
			-- 		end,
			-- 		"Diagnostic setloclist",
			-- 	},
			-- }, { mode = "n" })
			--
			-- wk.register({
			-- 	-- Don't copy the replaced text after pasting in visual mode
			-- 	-- https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text#Alternative_mapping_for_paste
			-- 	["p"] = { 'p:let @+=@0<CR>:let @"=@0<CR>', "Dont copy replaced text", opts = { silent = true } },
			-- }, { mode = "x" })
			--
			--
			--
			-- 	-- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
			-- 	-- http://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
			-- 	-- empty mode is same as using <cmd> :map
			-- 	-- also don't use g[j|k] when in operator pending mode, so it doesn't alter d, y or c behaviour
			--
			-- 	["j"] = {
			-- 		function()
			-- 			vim.api.nvim_exec(vim.v.count == 0 and "normal! gj" or "normal! j", false)
			-- 		end,
			-- 		"Move up",
			-- 		opts = { expr = true },
			-- 	},
			-- 	["k"] = {
			-- 		function()
			-- 			vim.api.nvim_exec(vim.v.count == 0 and "normal! gk" or "normal! k", false)
			-- 		end,
			-- 		"Move up",
			-- 		opts = { expr = true },
			-- 	},
			--
			-- 	-- new buffer
			-- 	["<leader>b"] = { "<cmd> enew <CR>", "New buffer" },
			-- 	["<leader>ch"] = { "<cmd> NvCheatsheet <CR>", "Mapping cheatsheet" },
			-- })
		end,
	},
}
