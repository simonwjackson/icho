{lib, ...}: {
  globals.mapleader = " ";

  plugins.flash.enable = true;

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
  '';

  keymaps = [
    {
      key = "s";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = lib.nixvim.mkRaw ''function() require("flash").jump() end'';
      options.desc = "Flash";
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
