{lib, ...}: {
  globals.mapleader = " ";

  plugins.flash = {
    enable = true;
    settings = {
      jump = {
        jumplist = true;
        pos = "start";
        history = true;
        register = true;
        nohlsearch = false;
      };
      char = {
        enabled = true;
      };
      modes = {
        char = {
          jump_labels = true;
        };
      };
    };
  };

  plugins.telescope = {
    settings = {
      defaults = {
        mappings = {
          n = {
            s = lib.nixvim.mkRaw ''
              function(prompt_bufnr)
                require("flash").jump({
                  pattern = "^",
                  label = { after = { 0, 0 } },
                  search = {
                    mode = "search",
                    exclude = {
                      function(win)
                        return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
                      end,
                    },
                  },
                  action = function(match)
                    local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
                    picker:set_selection(match.pos[1] - 1)
                  end,
                })
              end
            '';
          };
          i = {
            "<c-s>" = lib.nixvim.mkRaw ''
              function(prompt_bufnr)
                require("flash").jump({
                  pattern = "^",
                  label = { after = { 0, 0 } },
                  search = {
                    mode = "search",
                    exclude = {
                      function(win)
                        return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
                      end,
                    },
                  },
                  action = function(match)
                    local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
                    picker:set_selection(match.pos[1] - 1)
                  end,
                })
              end
            '';
          };
        };
      };
    };
  };

  extraConfigLua = ''
    function _G.set_terminal_keymaps()
    	local opts = { buffer = 0 }
    	vim.keymap.set("t", "<A-Esc>", [[<C-\><C-n>]], opts)
    	vim.keymap.set("t", "<A-h>", [[<Cmd>wincmd h<CR>]], opts)
    	vim.keymap.set("t", "<A-j>", [[<Cmd>wincmd j<CR>]], opts)
    	vim.keymap.set("t", "<A-k>", [[<Cmd>wincmd k<CR>]], opts)
    	vim.keymap.set("t", "<A-l>", [[<Cmd>wincmd l<CR>]], opts)
    	vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
    end

    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

    -- Flash jump to diagnostics
    function _G.flash_diagnostics()
      require("flash").jump({
        matcher = function(win)
          ---@param diag Diagnostic
          return vim.tbl_map(function(diag)
            return {
              pos = { diag.lnum + 1, diag.col },
              end_pos = { diag.end_lnum + 1, diag.end_col - 1 },
            }
          end, vim.diagnostic.get(vim.api.nvim_win_get_buf(win)))
        end,
        action = function(match, state)
          vim.api.nvim_win_call(match.win, function()
            vim.api.nvim_win_set_cursor(match.win, match.pos)
            vim.diagnostic.open_float()
          end)
          state:restore()
        end,
      })
    end

    -- Flash jump to beginning of words
    function _G.flash_words()
      require("flash").jump({
        search = {
          mode = function(str)
            return "\\<" .. str
          end,
        },
      })
    end
  '';

  keymaps = [
    {
      key = "<leader>d";
      mode = ["n"];
      action = lib.nixvim.mkRaw ''function() _G.flash_diagnostics() end'';
      options.desc = "Flash diagnostics";
    }
    {
      key = "s";
      mode = ["n" "x" "o"];
      action = lib.nixvim.mkRaw ''function() _G.flash_words() end'';
      options.desc = "Flash to word beginning";
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

    # Swap j/k with gj/gk
    {
      key = "j";
      mode = ["n" "v"];
      action = "gj";
      options.desc = "Move down by visual line";
    }
    {
      key = "k";
      mode = ["n" "v"];
      action = "gk";
      options.desc = "Move up by visual line";
    }
    {
      key = "gj";
      mode = ["n" "v"];
      action = "j";
      options.desc = "Move down by logical line";
    }
    {
      key = "gk";
      mode = ["n" "v"];
      action = "k";
      options.desc = "Move up by logical line";
    }
  ];

  plugins.better-escape = {
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

  plugins.which-key = {
    enable = true;
    autoLoad = true;
    settings = {
      delay = 200;
      expand = 1;
      notify = false;
      preset = false;
      replace = {
        desc = [
          [
            "<space>"
            "SPACE"
          ]
          [
            "<leader>"
            "SPACE"
          ]
          [
            "<[cC][rR]>"
            "RETURN"
          ]
          [
            "<[tT][aA][bB]>"
            "TAB"
          ]
          [
            "<[bB][sS]>"
            "BACKSPACE"
          ]
        ];
      };
      spec = [
        {
          __unkeyed-1 = "<leader>w";
          group = "windows";
          proxy = "<C-w>";
        }
      ];
      win = {
        border = "single";
      };
    };
  };
}
