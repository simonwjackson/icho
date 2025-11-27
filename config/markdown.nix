{...}: {
  plugins = {
    trouble.enable = true;
    markdown-preview.enable = true;
    render-markdown = {
      enable = true;
      settings = {
        file_types = ["markdown"];
        render_modes = ["n" "c" "t" "i"]; # render in insert mode too
        debounce = 100;
        anti_conceal = {
          enabled = true;
          above = 0; # buffer zone above cursor
          below = 0; # buffer zone below cursor
          ignore = {
            code_background = true;
            indent = true;
            sign = true;
            virtual_lines = true;
          };
        };
        heading.width = "full";
        code.width = "full";
      };
    };
  };

  keymaps = [
    {
      key = "<leader>m";
      action = "<Plug>MarkdownPreview";
      options = {
        desc = "Markdown Preview";
      };
    }
  ];
}
