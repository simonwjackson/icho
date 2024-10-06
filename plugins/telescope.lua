-- A highly extendable fuzzy finder over lists that is based on the Lua programming language and the Telescope picker.

return {
	{
		name = "telescope",
		dir = "@telescope@",
		lazy = false,
		config = function()
			require("telescope").load_extension("advanced_git_search")
		end,
		opts = {
			extensions = {
				advanced_git_search = {
					-- Browse command to open commits in browser. Default fugitive GBrowse.
					browse_command = "GBrowse",
					-- fugitive or diffview
					diff_plugin = "fugitive",
					-- customize git in previewer
					-- e.g. flags such as { "--no-pager" }, or { "-c", "delta.side-by-side=false" }
					git_flags = {},
					-- customize git diff in previewer
					-- e.g. flags such as { "--raw" }
					git_diff_flags = {},
					-- Show builtin git pickers when executing "show_custom_functions" or :AdvancedGitSearch
					show_builtin_git_pickers = false,
					entry_default_author_or_date = "author", -- one of "author" or "date"
					keymaps = {
						-- following keymaps can be overridden
						toggle_date_author = "<C-w>",
						open_commit_in_browser = "<C-o>",
						copy_commit_hash = "<C-y>",
						show_entire_commit = "<C-e>",
					},

					-- Telescope layout setup
					telescope_theme = {
						function_name_1 = {
							-- Theme options
						},
						function_name_2 = "dropdown",
						-- e.g. realistic example
						show_custom_functions = {
							layout_config = { width = 0.4, height = 0.4 },
						},
					},
				},
			},
			pickers = {
				colorscheme = {
					enable_preview = true,
				},
			},
		},
		keys = {
			-- {
			-- 	"<leader>pp",
			-- 	function()
			-- 		os.execute("nix run nixpkgs#tmux -- switch-client -l > /dev/null 2>&1")
			-- 	end,
			-- 	desc = "Project: Notes",
			-- },
			--
			-- {
			-- 	"<leader>pn",
			-- 	function()
			-- 		os.execute(
			-- 			'nix run nixpkgs#tmux -- new-session -d -c "/glacier/snowscape/notes" -s "notes" "nvim" > /dev/null 2>&1'
			-- 		)
			-- 		os.execute('nix run nixpkgs#tmux -- switch-client -t "notes"  > /dev/null 2>&1')
			-- 	end,
			-- 	desc = "Project: previous",
			-- },

			{
				"<leader>fn",
				"<cmd>enew<cr>",
				desc = "New file",
			},
			{
				"<leader>ff",
				"<cmd> Telescope find_files <CR>",
				desc = "Find files",
			},
			{
				"<leader>fa",
				"<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>",
				desc = "Find all",
			},
			{
				"<leader>fw",
				"<cmd> Telescope live_grep <CR>",
				desc = "Live grep",
			},
			{
				"<leader>fB",
				"<cmd> Telescope buffers <CR>",
				desc = "Find buffers",
			},
			{
				"<leader>fb",
				"<cmd> Telescope live_grep grep_open_files=true prompt_title=Find\\ in\\ Buffers <CR>",
				desc = "Find in buffers",
			},
			{
				"<leader>fh",
				"<cmd> Telescope help_tags <CR>",
				desc = "Help page",
			},
			{
				"<leader>fo",
				"<cmd> Telescope oldfiles <CR>",
				desc = "Find oldfiles",
			},
			{
				"<leader>fz",
				"<cmd> Telescope current_buffer_fuzzy_find <CR>",
				desc = "Find in current buffer",
			},
			{
				"<leader>gc",
				"<cmd> Telescope git_commits <CR>",
				desc = "Git commits",
			},
			{
				"<leader>gs",
				"<cmd> Telescope git_status <CR>",
				desc = "Git status",
			},

			-- TODO: Move these to which-key
			-- wk.register({
			-- 	["<leader>f"] = { name = "+file" },
			-- })
			{
				"<leader>kK",
				function()
					vim.cmd("WhichKey")
				end,
				desc = "Which-key all keymaps",
			},
			{
				"<leader>kk",
				function()
					local input = vim.fn.input("WhichKey: ")
					vim.cmd("WhichKey " .. input)
				end,
				desc = "Which-key query lookup",
			},
			-- {
			-- 	"<leader>jl",
			-- 	":FloatermNew --name=journallog --title=journal:log --height=1 journal log<cr>",
			-- 	desc = "Journal: Log",
			-- },
			-- {
			-- 	"<leader>jt",
			-- 	":FloatermNew --name=journaltask --title=journal:task --height=1 journal task<cr>",
			-- 	desc = "Journal: Task",
			-- },
		},
		branch = "0.1.x",
		dependencies = {
			{
				dir = "@advancedGitSearch@",
				name = "advanced-git-search",
				cmd = { "AdvancedGitSearch" },
				dependencies = {
					{
						dir = "@vimFugitive@",
						name = "vim-fugitive",
					},
					{
						name = "vim-rhubarb",
						dir = "@vimRhubarb@",
					},
					dir = "@diffview@",
					name = "diffview",
				},
			},
			{
				dir = "@plenary@",
				name = "plenary",
			},
			{
				name = "ripgrep",
				dir = "@ripgrep@",
			},
			{
				name = "fd",
				dir = "@fd@",
			},
			{
				dir = "@nvimWebDevicons@",
				name = "nvim-web-devicons",
			},
		},
	},
}
