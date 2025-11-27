{...}: {
  extraConfigLua = ''
    -- lspkind.lua
    local lspkind = require("lspkind")
    lspkind.init({
      symbol_map = {
        Supermaven = "󰁨",
      },
    })

    vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", {fg ="#6CC644"})
  '';

  plugins.cmp = {
    enable = true;
    autoEnableSources = true;
    settings = {
      mapping = {
        "<C-n>" = "cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select })";
        "<C-p>" = "cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select })";
        "<C-y>" = "cmp.mapping.confirm({ select = true })";
        "<C-e>" = "cmp.mapping.abort()";
        "<CR>" = "cmp.mapping.confirm({ select = false })";
      };
      sources = [
        # Group 1: Paths + AI + LSP (highest priority)
        {name = "claude_commands"; group_index = 1;}  # Only active in scratchpad (is_available check)
        {name = "async_path"; group_index = 1;}
        {name = "nvim_lsp"; group_index = 1;}
        # supermaven is added manually in agents/default.nix with group_index = 1
        # Group 2: Everything else (fallback)
        {name = "cmdline"; group_index = 2;}
        {name = "cmdline_history"; group_index = 2;}
        {name = "emoji"; group_index = 2;}
        {name = "nvim_lua"; group_index = 2;}
        {name = "zsh"; group_index = 2;}
      ];
    };
  };

  highlight = {
    CmpItemKindSupermaven = {
      fg = "#6FCBF5";
      bold = true;
    };
  };
}
