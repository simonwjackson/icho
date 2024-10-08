return {
	{
		name = "conform",
		dir = "@conform@",
		opts = {
			formatters = {
				shfmt = {
					prepend_args = { "-i", "2" },
				},
				injected = {
					options = {
						-- Set to true to ignore errors
						ignore_errors = false,
						-- Map of treesitter language to file extension
						-- A temporary file name with this extension will be generated during formatting
						-- because some formatters care about the filename.
						lang_to_ext = {
							lua = "lua",
							bash = "sh",
							c_sharp = "cs",
							elixir = "exs",
							javascript = "js",
							julia = "jl",
							latex = "tex",
							markdown = "md",
							python = "py",
							ruby = "rb",
							rust = "rs",
							teal = "tl",
							typescript = "ts",
						},
						-- Map of treesitter language to formatters to use
						-- (defaults to the value from formatters_by_ft)
						-- lang_to_formatters = {},
					},
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
