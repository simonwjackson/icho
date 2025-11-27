{pkgs, ...}: {
  extraPlugins = with pkgs; [
    vimPlugins.tmux-session-switcher
  ];

  plugins = {
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
      key = "<leader>p";
      action = "<CMD>TmuxSessionSwitch<CR>";
      options = {
        desc = "Open new tab with terminal in insert mode (nobuflisted)";
      };
    }
  ];

  highlight = {
    ToggleTermFloatBorder = {
      fg = "#7aa2f7";
      bg = "NONE";
    };
  };

  extraConfigLua = ''
    require('tmux-session-switcher').setup({
      paths = {
        -- HACK: Remove this so it so its useful for other people
        '/snowscape/code',
        '/snowscape/notes'
      },
    })
  '';
}
