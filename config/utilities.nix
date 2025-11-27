{lib, ...}: {
  plugins = {
    helpview.enable = true;
    direnv.enable = true;
    git-worktree.enable = true;
    firenvim.enable = true;
    grug-far.enable = true;

    lazydev = {
      enable = true;
      settings = {
        enabled = lib.nixvim.mkRaw "function(root_dir)\n  return vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled\nend\n";
        library = [
          "lazy.nvim"
          "LazyVim"
          {
            path = "LazyVim";
            words = [
              "LazyVim"
            ];
          }
        ];
        runtime = lib.nixvim.mkRaw "vim.env.VIMRUNTIME";
      };
    };
  };

  keymaps = [
    {
      key = "<leader>S";
      action = "<cmd>lua require('grug-far').toggle_instance({ instanceName = 'main' })<CR>";
      options = {
        desc = "Search and Replace";
      };
    }
  ];

  extraConfigLua = ''
    function Search_And_Replace()
      if vim.fn.mode() == 'v' or vim.fn.mode() == 'V' then
        require('grug-far').with_visual_selection({ transient = true })
      else
        require('grug-far').open({
          transient = true,
          prefills = { search = vim.fn.expand('<cword>') }
        })
      end
    end

    vim.api.nvim_create_autocmd({'UIEnter'}, {
      callback = function()
        local client = vim.api.nvim_get_chan_info(vim.v.event.chan).client
        if client ~= nil and client.name == "Firenvim" then
          vim.o.laststatus = 3
          vim.opt.showtabline = 0
          vim.api.nvim_set_keymap('n', '<C-s>', ':wq<CR>', { noremap = true, silent = true })
          vim.api.nvim_set_keymap('i', '<C-s>', '<Esc>:wq<CR>', { noremap = true, silent = true })
        end
      end
    })
  '';
}
