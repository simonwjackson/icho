{pkgs, ...}: {
  # NOTE: Using manualconfig to intigrate with Avante and CodeCompanion
  # INFO: https://github.com/yetone/avante.nvim/issues/175#issuecomment-2313749363

  extraPlugins = [
    pkgs.vimPlugins.markview-nvim
  ];

  extraConfigLua = ''
    require('markview').setup({
      filetypes = { "Avante", "codecompanion", "markdown", "norg", "org", "rmd", "vimwiki" },
      buf_ignore = {},
      max_length = 99999,
      max_file_length = 99999,
    });

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "codecompanion", "Avante" },
      callback = function()
        vim.api.nvim_set_hl(0, "MarkviewCode", { bg = "none" })
        vim.api.nvim_set_hl(0, "MarkviewCodeInfo", { bg = "none" })
      end
    })
  '';
}
