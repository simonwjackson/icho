{ ... }: {
  plugins.grug-far = {
    enable = true;
    settings = {
      windowCreationCommand = "leftabove vsplit";
      transient = true;
      wrap = false;
    };
  };

  keymaps = [
    {
      key = "<leader>S";
      action.__raw = ''
        function()
          -- Check if grug-far window exists and toggle it
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "grug-far" then
              vim.api.nvim_win_close(win, false)
              return
            end
          end
          require('grug-far').open({ windowCreationCommand = "topleft 60vsplit" })
        end
      '';
      options.desc = "Search and Replace";
    }
    {
      key = "<leader>S";
      mode = "v";
      action.__raw = ''
        function()
          -- Close existing grug-far window first
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "grug-far" then
              vim.api.nvim_win_close(win, false)
              break
            end
          end
          require('grug-far').with_visual_selection({ windowCreationCommand = "topleft 60vsplit" })
        end
      '';
      options.desc = "Search and Replace (selection)";
    }
  ];
}
