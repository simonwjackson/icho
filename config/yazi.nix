{
  plugins.yazi = {
    enable = true;
    settings = {
      open_for_directories = true;
      floating_window_scaling_factor = 0.8;
      yazi_floating_window_border = "rounded";
    };
  };

  keymaps = [
    {
      key = "<leader>fe";
      action = "<cmd>Yazi<cr>";
      mode = ["n" "v"];
      options.desc = "File explorer (yazi)";
    }
  ];

  # Disable netrw before plugins load (must be in extraConfigLuaPre)
  extraConfigLuaPre = ''
    vim.g.loaded_netrwPlugin = 1
  '';
}
