{pkgs, ...}: {
  plugins = {
    telescope = {
      enable = true;
    };

    yazi = {
      enable = true;
      settings = {
        floating_window_scaling_factor = 0.618;
      };
    };
  };

  extraPackages = [
    pkgs.neovim-remote
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

  '';

  keymaps = [
    {
      key = "<leader>fe";
      action = "<cmd>Yazi<CR>";
      options = {
        desc = "Open yazi at the current file";
      };
    }
    {
      key = "<leader>ff";
      action = "<cmd> Telescope find_files <CR>";
      options = {
        desc = "Find files";
      };
    }

    {
      key = "<leader>fF";
      action = "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>";
      options = {
        desc = "Find all files";
      };
    }

    {
      key = "<leader>fw";
      action = "<cmd> Telescope live_grep <CR>";
      options = {
        desc = "Live grep";
      };
    }

    {
      key = "<leader>fo";
      action = "<cmd> Telescope oldfiles <CR>";
      options = {
        desc = "Find oldfiles";
      };
    }
  ];
}
