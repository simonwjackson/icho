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
    diffview = {
      enable = true;
    };
  };

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
  '';

  keymaps = [
    {
      key = "<leader>gc";
      action = "<cmd> Telescope git_commits <CR>";
      options = {
        desc = "Git: commits";
      };
    }
    {
      key = "<leader>gg";
      action = "<cmd>LazyGit<CR>";
      options = {
        desc = "Git: Status";
      };
    }
    {
      key = "<leader>gd";
      action = "<cmd>DiffviewFileHistory<CR>";
      options = {
        desc = "Git: Diff";
      };
    }
    {
      key = "<leader>gd";
      action = "<cmd>DiffviewOpen<CR>";
      options = {
        desc = "Git: Diff";
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
