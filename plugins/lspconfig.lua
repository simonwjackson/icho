return {
	{
		dir = "@lspConfig@",
		name = "lspconfig",
		keys = {
			{
				"K",
				function()
					vim.lsp.buf.hover()
				end,
				desc = "LSP hover",
			},
			{
				"<leader>ca",
				function()
					vim.lsp.buf.code_action()
				end,
				desc = "LSP code action",
			},
		},
		init = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			require("lspconfig").lua_ls.setup({
				capabilities = capabilities,
			})

			require("lspconfig").ts_ls.setup({
				capabilities = capabilities,
			})

			require("lspconfig").yamlls.setup({
				capabilities = capabilities,
			})

			vim.cmd([[au BufRead,BufNewFile *.jq setfiletype jq]])

			require("lspconfig").jqls.setup({
				capabilities = capabilities,
			})

			require("lspconfig").jsonls.setup({
				capabilities = capabilities,
			})

			require("lspconfig").html.setup({
				capabilities = capabilities,
			})

			require("lspconfig").htmx.setup({
				capabilities = capabilities,
			})

			require("lspconfig").nixd.setup({
				capabilities = capabilities,
			})

			require("lspconfig").bashls.setup({
				capabilities = capabilities,
			})

			require("lspconfig").cssls.setup({
				capabilities = capabilities,
			})

			require("lspconfig").tailwindcss.setup({
				capabilities = capabilities,
			})

			require("lspconfig").elmls.setup({
				capabilities = capabilities,
			})

			require("lspconfig").eslint.setup({
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
					})
				end,
			})
		end,
	},
}
