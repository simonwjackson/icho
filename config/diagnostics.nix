{ ... }: {
  # Diagnostic display configuration
  diagnostic.settings = {
    virtual_text = {
      prefix = "";
      spacing = 2;
    };
    signs = true;
    underline = true;
    update_in_insert = false;
    severity_sort = true;
    float = {
      border = "rounded";
      source = "always";
    };
  };

  # Trouble.nvim for diagnostics panel
  plugins.trouble = {
    enable = true;
    settings = {
      auto_close = true;
      auto_preview = true;
      focus = true;
      modes = {
        diagnostics = {
          auto_open = false;
          auto_close = true;
          focus = true;
        };
      };
    };
  };

  keymaps = [
    { key = "<leader>xx"; action = "<cmd>Trouble diagnostics toggle<cr>"; options.desc = "Diagnostics (Trouble)"; }
    { key = "<leader>xX"; action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>"; options.desc = "Buffer Diagnostics (Trouble)"; }
    { key = "<leader>xs"; action = "<cmd>Trouble symbols toggle focus=false<cr>"; options.desc = "Symbols (Trouble)"; }
    { key = "<leader>xl"; action = "<cmd>Trouble lsp toggle focus=false win.position=right<cr>"; options.desc = "LSP Definitions/References (Trouble)"; }
    { key = "<leader>xL"; action = "<cmd>Trouble loclist toggle<cr>"; options.desc = "Location List (Trouble)"; }
    { key = "<leader>xQ"; action = "<cmd>Trouble qflist toggle<cr>"; options.desc = "Quickfix List (Trouble)"; }
  ];

  # Diagnostic signs in the gutter
  extraConfigLua = ''
    local signs = {
      Error = " ",
      Warn = " ",
      Hint = " ",
      Info = " ",
    }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end
  '';
}
