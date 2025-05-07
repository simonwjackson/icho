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

    	-- Make sure <A-.> also toggles the terminal when in terminal mode
    	vim.keymap.set("t", "<A-.>", [[<C-\><C-n><Cmd>ToggleTerm<CR>]], opts)
    end

    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
  '';

  keymaps = [
    {
      key = "<A-.>";
      action = "<cmd>ToggleTerm<CR>";
      options = {
        desc = "Toggle terminal";
        silent = true;
        noremap = true;
      };
    }
  ];

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
      highlights = {
        FloatBorder = {
          link = "FloatBorder";
        };
      };
      insert_mappings = true; # Allow the mapping to work in insert mode
      terminal_mappings = true; # Allow the mapping to work in terminal mode
      persist_size = true;
      persist_mode = true; # Remember terminal mode when toggling
      close_on_exit = true; # Close terminal when process exits
    };
  };
}
