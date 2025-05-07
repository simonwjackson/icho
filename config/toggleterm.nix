{pkgs, ...}: {
  extraPackages = [
    pkgs.neovim-remote
  ];

  extraConfigLua = ''
    function _G.set_terminal_keymaps()
    	local opts = { buffer = 0 }
    	vim.keymap.set("t", "<A-Esc>", [[<C-\><C-n>]], opts)
    	vim.keymap.set("t", "<A-h>", [[<Cmd>wincmd h<CR>]], opts)
    	vim.keymap.set("t", "<A-j>", [[<Cmd>wincmd j<CR>]], opts)
    	vim.keymap.set("t", "<A-k>", [[<Cmd>wincmd k<CR>]], opts)
    	vim.keymap.set("t", "<A-l>", [[<Cmd>wincmd l<CR>]], opts)
    	vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
    end

    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
  '';

  plugins.toggleterm = {
    enable = true;
    autoLoad = true;
    settings = {
      direction = "float";
      float_opts = {
        border = "curved";
        height = 30;
        width = 130;
      };
      open_mapping = "[[<a-.>]]";
      highlights = {
        FloatBorder = {
          link = "FloatBorder";
        };
      };
    };
  };
}

