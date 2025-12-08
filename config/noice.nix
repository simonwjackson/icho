{
  plugins.nui.enable = true;

  plugins.noice = {
    enable = true;
    settings = {
      # Presets
      presets = {
        command_palette = true;
        bottom_search = false;  # use same popup for / and ? as :
        long_message_to_split = true;
        lsp_doc_border = true;
      };

      # Cmdline replacement
      cmdline = {
        enabled = true;
        view = "cmdline_popup";
      };

      # Messages
      messages = {
        enabled = true;
        view = "mini";
      };

      # Disable notifications (using snacks.notifier instead)
      notify = {
        enabled = false;
      };

      # LSP overrides for nicer hover/signature
      lsp = {
        override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
          "cmp.entry.get_documentation" = true;
        };
        hover = {
          enabled = true;
        };
        signature = {
          enabled = true;
        };
        progress = {
          enabled = true;
          view = "mini";
        };
      };

      # Routes - keep notifications going through snacks
      routes = [
        {
          filter = {
            event = "notify";
          };
          view = "mini";
        }
      ];
    };
  };
}
