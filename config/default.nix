{lib, ...}: {
  plugins = {
    lspsaga.enable = true;
    noice = {
      enable = true;
      settings = {
        cmdline = {
          enabled = true;
        };
        health.chcker = false;
        messages.enabled = false;
        notify.enabled = false;
        popupmenu.enabled = true;
        smart_move.enabled = true;
      };
    };
    marks.enable = true;
    navbuddy = {
      enable = true;
      lsp = {
        autoAttach = true;
      };
    };

    kulala = {
      enable = true;
      settings = {
        additional_curl_options = {};
        debug = false;
        default_env = "dev";
        default_view = "body";
        environment_scope = "b";
        icons = {
          inlay = {
            done = "";
            error = "";
            loading = "";
          };
          lualine = "";
        };
      };
    };

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

    helpview.enable = true;
    direnv.enable = true;
    git-worktree.enable = true;
    glance.enable = true;
    improved-search.enable = true;
    auto-session.enable = true;
    comment.enable = true;
    firenvim.enable = true;
    lazygit.enable = true;
    gitsigns.enable = true;
    grug-far.enable = true;
    better-escape = {
      enable = true;
      settings = {
        timeout = 100;
        mappings = {
          c = {
            j = {
              k = "<CR>";
            };
            k = {
              l = "<Esc>";
            };
          };
          i = {
            j = {
              k = "<CR>";
            };
            k = {
              l = "<Esc>";
            };
          };
          s = {
            j = {
              k = "<CR>";
            };
            k = {
              l = "<Esc>";
            };
          };
          t = {
            j = {
              k = "<CR>";
            };
            k = {
              l = "<Esc>";
            };
          };
          v = {
            j = {
              k = "<CR>";
            };
            k = {
              l = "<Esc>";
            };
          };
        };
      };
    };
  };

  imports = [
    ./ai

    ./color.nix
    ./lsp.nix
    ./conform.nix
    ./dadbod.nix
    ./flash.nix
    ./lualine.nix
    ./markview.nix
    ./telescope.nix
    ./toggleterm.nix
    ./treesitter.nix
    ./which-key.nix
    ./osc52.nix
  ];

  keymaps = [
    {
      key = "<c-s>";
      action = "<cmd>update<CR>";
      options = {
        desc = "Save File";
      };
    }

    {
      key = "<leader>gg";
      action = "<cmd>LazyGitCurrentFile<CR>";
      options = {
        desc = "Lazy Git";
      };
    }

    {
      key = "<leader>gw";
      action = "<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>";
      options = {
        desc = "Git Worktrees";
      };
    }

    {
      key = "<leader>S";
      action = "<cmd>lua Search_And_Replace()<CR>";
      options = {
        desc = "Serch and Replace";
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
  '';

  highlight = {
    LazyGitBorder = {
      link = "FloatBorder";
    };
  };
}
