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
      sources = [
        {name = "async_path";}
        {name = "buffer";}
        {name = "cmdline";}
        {name = "cmdline_history";}
        {name = "emoji";}
        {name = "luasnip";}
        {name = "nvim_lsp";}
        {name = "nvim_lua";}
        {name = "supermaven";}
        {name = "zsh";}
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
