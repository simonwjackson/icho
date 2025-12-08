{ ... }: {
  plugins.cmp = {
    enable = true;
    autoEnableSources = true;

    settings = {
      sources = [
        { name = "nvim_lsp"; priority = 1000; }
        { name = "path"; priority = 300; }
        { name = "buffer"; priority = 200; keyword_length = 3; }
      ];

      mapping = {
        "<C-n>" = "cmp.mapping.select_next_item()";
        "<C-p>" = "cmp.mapping.select_prev_item()";
        "<C-d>" = "cmp.mapping.scroll_docs(-4)";
        "<C-f>" = "cmp.mapping.scroll_docs(4)";
        "<C-Space>" = "cmp.mapping.complete()";
        "<C-e>" = "cmp.mapping.abort()";
        "<CR>" = "cmp.mapping.confirm({ select = false })";
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

      formatting = {
        format = ''
          function(entry, vim_item)
            local source_names = {
              nvim_lsp = "[LSP]",
              path = "[Path]",
              buffer = "[Buf]",
            }
            vim_item.menu = source_names[entry.source.name] or ""
            return vim_item
          end
        '';
      };
    };
  };

  # Enable cmp sources
  plugins.cmp-nvim-lsp.enable = true;
  plugins.cmp-path.enable = true;
  plugins.cmp-buffer.enable = true;
}
