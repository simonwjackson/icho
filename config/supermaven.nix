{pkgs, ...}: {
  extraPlugins = with pkgs; [
    vimPlugins.supermaven-nvim # AI code completion
  ];

  extraConfigLua = ''
    -- Workaround for supermaven initialization issues
    local ok, supermaven = pcall(require, "supermaven-nvim")
    if ok then
      supermaven.setup({
        keymaps = {
          accept_suggestion = "<Tab>",
          clear_suggestion = "<C-]>",
          accept_word = "<C-j>",
        },
        ignore_filetypes = { cpp = true }, -- or { "cpp", }
        log_level = "off", -- set to "off" to disable logging completely
        disable_inline_completion = false, -- disables inline completion for use with cmp
        disable_keymaps = false, -- disables built in keymaps for more manual control
        condition = function()
          return false
        end -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
      })
    end
  '';
}
