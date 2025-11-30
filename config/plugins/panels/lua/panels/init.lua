-- Panels: Window panel management using edgy.nvim
local M = {}

-- Configuration (set via Nix)
M.config = {
  sizes = {
    right = 0.381,
    left = 0.234,
    bottom = 0.381,
  },
  animate = false,
}

-- Setup function (called from Nix)
function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)

  -- No global statusline
  vim.opt.laststatus = 0

  -- Disable individual statuslines
  vim.api.nvim_set_hl(0, "Statusline", { link = "WinSeparator" })
  vim.api.nvim_set_hl(0, "StatuslineNC", { link = "WinSeparator" })
  vim.opt.statusline = "%{repeat('─', winwidth(0))}"
  vim.wo.statusline = ""

  require("edgy").setup({
    options = {
      right = { size = M.config.sizes.right },
      left = { size = M.config.sizes.left },
      bottom = { size = M.config.sizes.bottom },
    },
    animate = {
      enabled = M.config.animate,
    },
    right = {
      {
        ft = "grug-far",
        title = "Find & Replace",
        size = { width = 0.3 },
      },
      {
        title = "Claude Code",
        ft = "terminal",
        filter = function(buf)
          local bufname = vim.api.nvim_buf_get_name(buf)
          return bufname:match("claude") ~= nil
        end,
      },
      {
        title = "Agent Input",
        ft = "markdown",
        size = { height = 0.381 },
        filter = function(buf)
          return vim.api.nvim_buf_get_name(buf):match("agent%-input$") ~= nil
        end,
      },
    },
    left = {
      {
        title = "Neo-Tree Git",
        ft = "neo-tree",
        size = {
          height = 0.616,
          width = 0.144,
        },
        filter = function(buf)
          return vim.b[buf].neo_tree_source == "git_status"
        end,
        pinned = true,
        collapsed = false,
        open = "Neotree position=left git_status",
      },
      {
        ft = "trouble",
        filter = function(buf, win)
          return vim.w[win].trouble and vim.w[win].trouble.mode == "symbols"
        end,
        title = "Symbols",
        size = { width = 0.381 },
      },
    },
    bottom = {
      {
        ft = "OverseerList",
        title = "Overseer",
        size = { width = 0.381 },
        filter = function(buf)
          return vim.bo[buf].filetype == "OverseerList"
        end,
      },
      {
        ft = "OverseerOutput",
        title = "Task Output",
        size = { width = 0.616 },
        filter = function(buf)
          return vim.bo[buf].filetype == "OverseerOutput"
        end,
      },
      {
        ft = "trouble",
        filter = function(buf, win)
          return vim.w[win].trouble and vim.w[win].trouble.mode == "diagnostics"
        end,
        title = "Diagnostics",
        size = { height = 0.381 },
      },
      {
        ft = "trouble",
        filter = function(buf, win)
          return vim.w[win].trouble and vim.w[win].trouble.mode == "todo"
        end,
        title = "Todo",
        size = { height = 0.381 },
      },
      { ft = "qf", title = "QuickFix" },
    },
  })
end

-- Toggle panel position
function M.toggle(position)
  require("edgy").toggle(position)
end

return M
