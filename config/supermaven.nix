{ pkgs, ... }: {
  extraPlugins = with pkgs.vimPlugins; [
    supermaven-nvim
  ];

  extraConfigLua = ''
    require('supermaven-nvim').setup({
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-j>",
      },
      ignore_filetypes = { "snacks_terminal" },
      color = {
        suggestion_color = "#585b70",
      },
      log_level = "off",
    })
  '';
}
