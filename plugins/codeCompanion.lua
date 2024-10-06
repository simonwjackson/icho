return {
	{
		dir = "@codeCompanion@",
		name = "code-companion",
		config = function()
			require("codecompanion").setup({
				strategies = {
					chat = {
						adapter = "anthropic",
					},
					inline = {
						adapter = "anthropic",
					},
					agent = {
						adapter = "anthropic",
					},
				},
				adapters = {
					anthropic = function()
						return require("codecompanion.adapters").extend("anthropic", {})
					end,
				},
			})
		end,
		dependencies = {
			{
				name = "edgy",
				dir = "@edgyNvim@",
				event = "VeryLazy",
				init = function()
					vim.opt.laststatus = 3
					vim.opt.splitkeep = "screen"
				end,
				opts = {
					right = {
						{ ft = "codecompanion", title = "Code Companion Chat", size = { width = 0.45 } },
					},
				},
			},
			{
				name = "plenary",
				dir = "@plenary@",
			},
			{
				name = "treesitter-yaml",
				dir = "@treesitterYaml@",
			},
			{
				name = "telescope",
				dir = "@telescope@",
			},
			{
				name = "dressing",
				dir = "@dressing@", -- Optional: Improves the default Neovim UI
			},
		},
	},
}
