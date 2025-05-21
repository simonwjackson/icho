{pkgs, ...}: {
  extraPlugins = [
    pkgs.vimPlugins.advanced-git-search-nvim
    pkgs.vimPlugins.plenary-nvim # Required dependency
    pkgs.vimPlugins.telescope-nvim # For file selection
  ];

  plugins = {
    lazygit = {
      enable = true;
      settings.use_neovim_remote = 1;
    };
  };

  extraConfigLua = ''
    -- MiniDiff highlight improvements for better contrast

    vim.api.nvim_set_hl(0, 'DiffChange', { bg = '#4A4123', fg = '#F9E2AF' }) -- Dark yellow bg with yellow fg
    -- Advanced Git Search
    require('telescope').load_extension('advanced_git_search')

    -- Close DiffviewFilePanel with 'q'
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "DiffviewFiles",
      callback = function()
        vim.api.nvim_buf_set_keymap(0, 'n', 'q', ':DiffviewClose<CR>', { noremap = true, silent = true })
      end
    })
  '';

  keymaps = [
    {
      key = "<leader>gs";
      action = "<cmd>lua require('edgy').toggle('left')<CR>";
      options = {
        desc = "Git: Status";
      };
    }
    {
      key = "<leader>gg";
      action = "<cmd>LazyGit<CR>";
      options = {
        desc = "Git: LazyGit";
      };
    }
    {
      key = "<leader>gd";
      action = "<cmd>lua MiniDiff.toggle_overlay()<CR>";
      options = {
        desc = "Git: Search commit content";
      };
    }
    {
      key = "<leader>gw";
      action = "<cmd>Telescope advanced_git_search search_log_content<CR>";
      options = {
        desc = "Git: Search commit content";
      };
    }
  ];
}
