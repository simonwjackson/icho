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

  # Todo comments highlighting
  plugins.todo-comments = {
    enable = true;
    settings = {
      signs = true;
      keywords = {
        FIX = { icon = " "; color = "error"; alt = [ "FIXME" "BUG" "FIXIT" "ISSUE" ]; };
        TODO = { icon = " "; color = "info"; };
        HACK = { icon = " "; color = "warning"; };
        WARN = { icon = " "; color = "warning"; alt = [ "WARNING" "XXX" ]; };
        PERF = { icon = " "; color = "default"; alt = [ "OPTIM" "PERFORMANCE" "OPTIMIZE" ]; };
        NOTE = { icon = " "; color = "hint"; alt = [ "INFO" ]; };
        TEST = { icon = "⏲ "; color = "test"; alt = [ "TESTING" "PASSED" "FAILED" ]; };
      };
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
    { key = "<leader>xt"; action = "<cmd>Trouble todo toggle<cr>"; options.desc = "Todo (Trouble)"; }
    { key = "]t"; action.__raw = "function() require('todo-comments').jump_next() end"; options.desc = "Next todo comment"; }
    { key = "[t"; action.__raw = "function() require('todo-comments').jump_prev() end"; options.desc = "Previous todo comment"; }
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
