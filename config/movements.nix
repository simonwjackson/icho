{lib, ...}: {
  globals.mapleader = " ";

  plugins.flash.enable = true;

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
