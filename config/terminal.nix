{
  keymaps = [
    { key = "<A-h>"; action = "<Cmd>wincmd h<CR>"; options.desc = "Window left"; }
    { key = "<A-j>"; action = "<Cmd>wincmd j<CR>"; options.desc = "Window down"; }
    { key = "<A-k>"; action = "<Cmd>wincmd k<CR>"; options.desc = "Window up"; }
    { key = "<A-l>"; action = "<Cmd>wincmd l<CR>"; options.desc = "Window right"; }
  ];

  extraConfigLua = ''
    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set("t", "<A-Esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "<A-h>", [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set("t", "<A-j>", [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set("t", "<A-k>", [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set("t", "<A-l>", [[<Cmd>wincmd l<CR>]], opts)
    end

    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
  '';
}
