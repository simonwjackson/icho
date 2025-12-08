{ pkgs, ... }: {
  # render-markdown: Renders markdown in-buffer with nice formatting
  plugins.render-markdown = {
    enable = true;
    settings = {
      render_modes = [ "n" "c" "t" "i" ];  # render in insert mode too
      anti_conceal = {
        enabled = true;
        above = 0;
        below = 0;
        ignore = {
          code_background = true;
          indent = true;
          sign = true;
          virtual_lines = true;
        };
      };
      heading = {
        enabled = true;
        icons = [ "󰲡 " "󰲣 " "󰲥 " "󰲧 " "󰲩 " "󰲫 " ];
      };
      code = {
        enabled = true;
        sign = false;
        style = "full";
        border = "thin";
      };
      bullet = {
        enabled = true;
        icons = [ "●" "○" "◆" "◇" ];
      };
      checkbox = {
        enabled = true;
        unchecked = { icon = " "; };
        checked = { icon = " "; };
      };
      quote = {
        enabled = true;
        icon = "▐ ";
      };
      pipe_table = {
        enabled = true;
        style = "full";
      };
    };
  };

  # markdown-preview: Live preview in browser
  extraPlugins = [ pkgs.vimPlugins.markdown-preview-nvim ];

  extraConfigLua = ''
    vim.g.mkdp_auto_close = 1
    vim.g.mkdp_refresh_slow = 0
    vim.g.mkdp_browser = ""  -- use default browser
  '';

  keymaps = [
    { key = "<leader>mp"; action = "<cmd>MarkdownPreviewToggle<cr>"; options.desc = "Toggle Markdown Preview"; }
  ];
}
