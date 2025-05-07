{
  pkgs,
  lib,
  ...
}: {
  # filetype = {
  #   extension = {
  #     astro = "astro";
  #   };
  # };

  extraPlugins = [
    pkgs.vimPlugins.tmux-session-switcher
  ];

  imports = [
    ./claude-code
    ./clipboard.nix
    ./color.nix
    ./conform.nix
    ./dadbod.nix
    ./fidget.nix
    ./files.nix
    ./flash.nix
    ./git
    ./lsp.nix
    ./lualine.nix
    # ./markview.nix
    ./overseer.nix
    ./supermaven.nix
    ./telescope.nix
    ./toggleterm.nix
    ./treesitter.nix
    ./which-key.nix
  ];

  plugins = {
    # Keyboard
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

    # HTTP
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
    rest.enable = true;

    # UI
    otter.enable = true;
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
    noice = {
      enable = true;
      settings = {
        cmdline = {
          enabled = true;
        };
        health.checker = false;
        messages = {
          enabled = false;
          view = "notify";
          view_error = "notify";
          view_warn = "notify";
          view_history = "messages";
          view_search = "virtualtext";
        };
        notify.enabled = false;
        popupmenu.enabled = true;
        smart_move.enabled = true;
      };
    };

    # QOL
    vim-suda = {
      enable = true;
    };

    # Editing
    vim-matchup = {
      enable = true;
      treesitter.enable = true;
    };
    repeat.enable = true;

    # Syntax
    todo-comments.enable = true;
    typescript-tools.enable = true;
    tailwind-tools.enable = true;
    scope.enable = true;
    refactoring = {
      enable = true;
      enableTelescope = true;
    };
    qmk = {
      enable = true;
      settings = {
        name = "zmk";
        layout = [
          "x x"
          "x^x"
        ];
      };
    };
    lspsaga.enable = true;
    nvim-surround.enable = true;
    # obsidian.enable = true;

    marks.enable = true;
    navbuddy = {
      enable = true;
      lsp = {
        autoAttach = true;
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
    grug-far.enable = true;
  };

  autoCmd = [
    {
      event = "TermClose";
      pattern = "*";
      # Close the tab if there are no other splits
      command =
        # vim
        ''
          if !v:event.status && bufname('%') == "" && tabpagewinnr(tabpagenr()) == 1
            quit!
          endif
        '';
    }
  ];

  keymaps = [
    {
      key = "<A-C-l>";
      action = "<cmd>tabnext<CR>";
      options = {
        desc = "Next Tab";
      };
    }
    {
      key = "<A-C-h>";
      action = "<cmd>tabprevious<CR>";
      options = {
        desc = "Previous Tab";
      };
    }
    {
      key = "<A-C-j>";
      action = "<cmd>bnext<CR>";
      options = {
        desc = "Next buffer";
      };
    }
    {
      key = "<A-C-k>";
      action = "<cmd>bprevious<CR>";
      options = {
        desc = "Previous buffer";
      };
    }
    {
      key = "<leader>p";
      action = "<CMD>TmuxSessionSwitch<CR>";
      options = {
        desc = "Open new tab with terminal in insert mode (nobuflisted)";
      };
    }
    {
      key = "<C-t>";
      action = ":tabnew<CR>:terminal<CR>:startinsert<CR>";
      options = {
        desc = "Open new tab with terminal in insert mode (nobuflisted)";
      };
    }
    {
      key = "<A-h>";
      action = "<Cmd>wincmd h<CR>";
    }
    {
      key = "<A-j>";
      action = "<Cmd>wincmd j<CR>";
    }
    {
      key = "<A-k>";
      action = "<Cmd>wincmd k<CR>";
    }
    {
      key = "<A-l>";
      action = "<Cmd>wincmd l<CR>";
    }
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

    # {
    #   key = "<leader>gw";
    #   action = "<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>";
    #   options = {
    #     desc = "Git Worktrees";
    #   };
    # }
    {
      key = "<leader>S";
      action = "<cmd>lua Search_And_Replace()<CR>";
      options = {
        desc = "Serch and Replace";
      };
    }
  ];

  extraConfigLua = ''
    local opt = vim.opt

    opt.shortmess:append('filnxtToOCcIF')

    -- Persist undo history between sessions
    opt.undofile = true;

    --- CUSTOM ---
    opt.splitkeep = "screen" -- keeps the same screen screen lines in all split windows
    opt.signcolumn = "yes"

    opt.splitbelow = true
    opt.splitright = true
    opt.termguicolors = true
    opt.timeoutlen = 400
    opt.undofile = true
    opt.scrollback = 100000

    -- Indenting
    opt.expandtab = true
    opt.shiftwidth = 2
    opt.smartindent = true
    opt.tabstop = 2
    opt.softtabstop = 2

    opt.fillchars = {
      eob = " ",
      -- fold = ' ',
      diff = '╱',
      -- wbr = '─',
      -- msgsep = '─',
      -- horiz = ' ',
      -- horizup = '│',
      -- horizdown = '│',
      -- vertright = '│',
      -- vertleft = '│',
      -- verthoriz = '│',
    }
    opt.ignorecase = true
    opt.smartcase = true
    opt.mouse = "a"

    -- Numbers
    opt.number = false
    opt.numberwidth = 2
    opt.ruler = false

    -- Command line
    opt.cmdheight = 0

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

    require('tmux-session-switcher').setup({
      paths = {
        -- HACK: Remove this so it so its useful for other people
        '/snowscape/code',
        '/snowscape/notes'
      },
    })

    vim.api.nvim_create_autocmd({'UIEnter'}, {
      callback = function()
        local client = vim.api.nvim_get_chan_info(vim.v.event.chan).client
        if client ~= nil and client.name == "Firenvim" then
          vim.o.laststatus = 0
          vim.opt.showtabline = 0
          vim.api.nvim_set_keymap('n', '<C-s>', ':wq<CR>', { noremap = true, silent = true })
          vim.api.nvim_set_keymap('i', '<C-s>', '<Esc>:wq<CR>', { noremap = true, silent = true })
        end
      end
    })

    vim.api.nvim_set_hl(0, 'DiffDelete', { bg = 'NONE', fg = '#2F4146' })
  '';

  highlight = {
    LazyGitBorder = {
      link = "FloatBorder";
    };
  };
}
