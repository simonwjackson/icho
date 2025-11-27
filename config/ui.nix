{...}: {
  plugins = {
    web-devicons.enable = true;

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
  };

  keymaps = [
    {
      key = "<A-m>";
      action = "<cmd>ZenMode<cr>";
      options = {
        desc = "Toggle zen mode";
      };
    }
  ];

  highlight = {
    LazyGitBorder = {
      link = "FloatBorder";
    };
  };
}
