{pkgs, ...}: {
  # NOTE: Using manualconfig to intigrate with Avante and Code companion
  # https://github.com/yetone/avante.nvim/issues/175#issuecomment-2313749363

  extraPlugins = [
    pkgs.vimPlugins.markview-nvim
  ];

  extraConfigLua = ''
    require('markview').setup({
      filetypes = { "markdown", "norg", "rmd", "org", "vimwiki", "Avante" },
      buf_ignore = {},
      max_length = 99999,
      max_file_length = 99999;
    });
  '';
}
