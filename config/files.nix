{pkgs, ...}: {
  extraPackages = [
    pkgs.neovim-remote
    pkgs.lf
  ];

  extraPlugins = [
    pkgs.vimPlugins.lf-nvim
  ];

  extraConfigLua = ''
    -- Advanced Git Search
    require('telescope').load_extension('advanced_git_search')

    -- Close DiffviewFilePanel with 'q'
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "DiffviewFiles",
      callback = function()
        vim.api.nvim_buf_set_keymap(0, 'n', 'q', ':DiffviewClose<CR>', { noremap = true, silent = true })
      end
    })

    local fn = vim.fn
    local o = vim.o

    -- lf Defaults
    require("lf").setup({
      -- default_action = "drop", -- default action when `Lf` opens a file
      default_actions = { -- default action keybindings
        ["<C-t>"] = "tabedit",
        ["<C-x>"] = "split",
        ["<C-v>"] = "vsplit",
        ["<C-o>"] = "tab drop",
        -- ["<Return>"] = "edit",
        -- ["<Enter>"] = "edit",
      },

      winblend = 0, -- psuedotransparency level
      dir = "", -- directory where `lf` starts ('gwd' is git-working-directory, ""/nil is CWD)
      direction = "float", -- window type: float horizontal vertical
      border = "curved", -- border kind: single double shadow curved
      height = fn.float2nr(fn.round(0.75 * o.lines)), -- height of the *floating* window
      width = fn.float2nr(fn.round(0.75 * o.columns)), -- width of the *floating* window
      escape_quit = true, -- map escape to the quit command (so it doesn't go into a meta normal mode)
      focus_on_open = true, -- focus the current file when opening Lf (experimental)
      mappings = true, -- whether terminal buffer mapping is enabled
      default_file_manager = true, -- make lf default file manager


      -- -- Layout configurations
      layout_mapping = "<M-u>", -- resize window with this key
      views = { -- window dimensions to rotate through
        {width = 0.800, height = 0.800},
        {width = 0.600, height = 0.600},
        {width = 0.950, height = 0.950},
        {width = 0.500, height = 0.500, col = 0, row = 0},
        {width = 0.500, height = 0.500, col = 0, row = 0.5},
        {width = 0.500, height = 0.500, col = 0.5, row = 0},
        {width = 0.500, height = 0.500, col = 0.5, row = 0.5},
      }
    })
  '';

  keymaps = [
    {
      key = "<leader>fe";
      action = "<Cmd>Lf<CR>";
      options = {
        desc = "Open lf file manager";
        silent = true;
        noremap = true;
      };
    }
  ];
}
