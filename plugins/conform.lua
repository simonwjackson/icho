return {
	{
		name = "conform",
		dir = "@conform@",
		opts = {
			formatters = {
				shfmt = {
					prepend_args = { "-i", "2" },
				},
			},
			formatters_by_ft = {
				lua = { "stylua" },
				nix = { "alejandra" },
				awk = { "awk" },
				sh = { "shfmt" },
				elm = { "elm_format" },
				-- typescript = { { "prettierd", "prettier" } },
				-- typescriptreact = { { "prettierd", "prettier" } },
				-- javascript = { { "prettierd", "prettier" } },
				-- javascriptreact = { { "prettierd", "prettier" } },
				-- TODO: ESlint_d might need specific eslint/node deps to work correctly
				-- typescript = { "prettierd" },
				-- javascriptreact = { "prettierd" },
				-- typescriptreact = { "prettierd" },
				svelte = { "prettierd" },
				css = { "prettierd" },
				html = { "prettierd" },
				json = { "jq" },
				yaml = { "yq" },
				-- markdown = { "prettierd" },
				just = { "just" },
				python = { "isort", "black" },
				-- # TODO: Add tailwind
				-- rustywind
			},
			log_level = vim.log.levels.INFO,
			-- format_after_save = {
			-- 	lsp_fallback = true,
			-- },
			format_on_save = {
				-- I recommend these options. See :help conform.format for details.
				lsp_fallback = true,
				timeout_ms = 500,
				async = true,
			},
		},
	},
}
