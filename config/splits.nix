{pkgs, ...}: {
  extraPlugins = with pkgs; [
    vimPlugins.edgy-nvim
  ];

  extraConfigLua = ''
    -- No global statusline
    vim.opt.laststatus = 0

    -- Disable individual statuslines
    vim.api.nvim_set_hl(0, 'Statusline', {link = 'WinSeparator'})
    vim.api.nvim_set_hl(0, 'StatuslineNC', {link = 'WinSeparator'})
    vim.opt.statusline = "%{repeat('─', winwidth(0))}"
    vim.wo.statusline = ""

    -- TODO: Try nixvim's edgy.nvim again soon
    require("edgy").setup({
      -- close_when_all_hidden = false,
      options = {
        right = { size = 0.381 },
        left = { size = 0.234 }, -- or 0.144
        bottom = { size = 0.381 },
      },
      animate = {
       enabled = false,
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
            width = 0.144
          },
          filter = function(buf)
            return vim.b[buf].neo_tree_source == "git_status"
          end,
          pinned = true,
          collapsed = false, -- show window as closed/collapsed on start
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
  '';

  keymaps = [
    {
      key = "<leader>gs";
      action = "<cmd>lua require('edgy').toggle('left')<CR>";
      options = {
        desc = "Git: Status";
      };
    }
  ];
}
