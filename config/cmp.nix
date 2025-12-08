{ ... }: {
  extraConfigLua = ''
    -- Limit completion popup height
    vim.opt.pumheight = 5

    -- lspkind setup
    local lspkind = require("lspkind")
    lspkind.init({
      symbol_map = {
        Supermaven = "󰁨",
      },
    })

    vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", {fg ="#6CC644"})
  '';

  plugins.lspkind = {
    enable = true;
    settings.cmp = {
      enable = true;
      max_width = 50;
      ellipsis_char = "...";
    };
  };

  plugins.cmp = {
    enable = true;
    autoEnableSources = true;

    settings = {
      sources = [
        # Group 1: Paths + AI + LSP (highest priority)
        { name = "async_path"; group_index = 1; }
        { name = "nvim_lsp"; group_index = 1; }
        # Group 2: Everything else (fallback)
        { name = "nvim_lua"; group_index = 2; }
        { name = "buffer"; group_index = 2; keyword_length = 3; }
      ];

      mapping = {
        "<C-n>".__raw = "cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select })";
        "<C-p>".__raw = "cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select })";
        "<C-y>".__raw = "cmp.mapping.confirm({ select = true })";
        "<C-d>".__raw = "cmp.mapping.scroll_docs(-4)";
        "<C-f>".__raw = "cmp.mapping.scroll_docs(4)";
        "<C-Space>".__raw = "cmp.mapping.complete()";
        "<C-e>".__raw = "cmp.mapping.abort()";
        "<CR>".__raw = "cmp.mapping.confirm({ select = false })";
      };

      window = {
        completion = {
          border = "rounded";
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None";
        };
        documentation = {
          border = "rounded";
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None";
        };
      };

    };
  };

  highlight = {
    CmpItemKindSupermaven = {
      fg = "#6FCBF5";
      bold = true;
    };
  };

  # Enable cmp sources
  plugins.cmp-nvim-lsp.enable = true;
  plugins.cmp-buffer.enable = true;
  plugins.cmp-nvim-lua.enable = true;
  plugins.cmp-async-path.enable = true;
}
