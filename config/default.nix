{
  pkgs,
  lib,
  ...
}: {
  extraPlugins = with pkgs; [
    vimPlugins.tmux-session-switcher
  ];

  imports = [
    ./agents
    ./clipboard.nix
    ./color.nix
    ./completion.nix
    ./database.nix
    ./fidget.nix
    ./files.nix
    ./formatting.nix
    ./git.nix
    ./gutter.nix
    ./lsp.nix
    ./movements.nix
    ./snippets.nix
    ./sessions
    ./splits.nix
    ./splash.nix
    ./tabs
    ./tasks.nix
    ./telescope.nix
    ./treesitter.nix
  ];

  plugins = {
    trouble.enable = true;
    markdown-preview.enable = true;
    neo-tree = {
      enable = true;
      filesystem = {
        hijackNetrwBehavior = "disabled";
      };
    };
    toggleterm = {
      enable = true;
      settings = {
        open_mapping = "[[<a-.>]]";
        direction = "float";
        float_opts = {
          border = "curved";
          width.__raw = ''
            function()
              return math.floor(vim.o.columns * 0.618)
            end
          '';
          height.__raw = ''
            function()
              return math.floor(vim.o.lines * 0.618)
            end
          '';
          winblend = 0;
        };
        highlights = {
          FloatBorder = {
            guifg = "#7aa2f7";
            guibg = "NONE";
          };
        };
      };
    };

    web-devicons.enable = true;

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
          backdrop = 1;
          width = 0.8;
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

    # # Syntax
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
      key = "<leader>m";
      action = "<Plug>MarkdownPreview";
      options = {
        desc = "Markdown Preview";
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
      action = "<cmd>lua require('grug-far').toggle_instance({ instanceName = 'main' })<CR>";
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
      diff = '╱',
      stl = ' ',  -- statusline fill char (space to hide statuslines)
      stlnc = ' ', -- non-current window statusline fill char
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

    -- Disable status line
    opt.laststatus = 3

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
          vim.o.laststatus = 3
          vim.opt.showtabline = 0
          vim.api.nvim_set_keymap('n', '<C-s>', ':wq<CR>', { noremap = true, silent = true })
          vim.api.nvim_set_keymap('i', '<C-s>', '<Esc>:wq<CR>', { noremap = true, silent = true })
        end
      end
    })
  '';

  highlight = {
    LazyGitBorder = {
      link = "FloatBorder";
    };
    ToggleTermFloatBorder = {
      fg = "#7aa2f7"; # Blue color, you can change this
      bg = "NONE";
    };
  };
}
