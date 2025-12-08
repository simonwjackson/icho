{ pkgs, resession-nvim, ... }:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "resession-nvim";
      src = resession-nvim;
    })
  ];

  extraConfigLua = ''
    require("resession").setup({
      autosave = {
        enabled = true,
        interval = 60,
        notify = false,
      },
    })

    -- Autoload session for current directory
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        -- Only load session if no files were passed as arguments
        if vim.fn.argc(-1) == 0 then
          require("resession").load(vim.fn.getcwd(), { dir = "dirsession", silence_errors = true })
        end
      end,
      nested = true,
    })

    -- Autosave session on exit
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        require("resession").save(vim.fn.getcwd(), { dir = "dirsession", notify = false })
      end,
    })
  '';
}
