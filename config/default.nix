{lib, ...}: {
  imports = [
    ./ai

    # ./clipboard.nix
    ./color.nix
    ./conform.nix
    ./dadbod.nix
    ./flash.nix
    ./lsp.nix
    ./lualine.nix
    ./markview.nix
    ./overseer.nix
    ./telescope.nix
    ./toggleterm.nix
    ./treesitter.nix
    ./which-key.nix
  ];

  plugins = {
    dressing = {
      enable = true;
      settings = {
        input = {
          enabled = true;
        };
        select = {
          enabled = true;
        };
      };
    };
    zen-mode = {
      enable = true;
      settings = {
        window = {
          backdrop = 0.95;
          width = 120;
          height = 1;
        };
      };
    };
    vim-suda = {
      enable = true;
    };
    vim-matchup = {
      enable = true;
      treesitter.enable = true;
    };
    typescript-tools.enable = true;
    todo-comments.enable = true;
    tailwind-tools.enable = true;
    scope.enable = true;
    smear-cursor = {
      enable = true;
      settings = {
        stiffness = 0.8;
        trailing_stiffness = 0.5;
        distance_stop_animating = 0.5;
        hide_target_hack = false;
        legacy_computing_symbols_support = true;
      };
    };
    rest.enable = true;
    refactoring = {
      enable = true;
      enableTelescope = true;
    };
    repeat.enable = true;
    qmk.enable = true;
    qmk.settings.name = "zmk";
    qmk.settings.layout = [
      "x x"
      "x^x"
    ];
    lspsaga.enable = true;
    nvim-surround.enable = true;
    # obsidian.enable = true;
    otter.enable = true;
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
    # gitsigns.enable = true;
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

  keymaps = [
    {
      key = "<A-m>";
      action = "<cmd>ZenMode<cr>";
      options = {
        desc = "Toggle zen mode";
      };
    }
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

  extraConfigLua =
    # Lua
    ''
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

      vim.opt.signcolumn = "yes";
    '';

  highlight = {
    LazyGitBorder = {
      link = "FloatBorder";
    };
  };
}
