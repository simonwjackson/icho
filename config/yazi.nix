{
  plugins.yazi = {
    enable = true;
    settings = {
      open_for_directories = true;
      floating_window_scaling_factor = 0.8;
      yazi_floating_window_border = "rounded";
      hooks = {
        yazi_opened.__raw = ''
          function(preselected_path, yazi_buffer_id, config)
            -- Create dim overlay
            vim.api.nvim_set_hl(0, "YaziDim", { bg = "#000000", blend = 20 })
            local dim_buf = vim.api.nvim_create_buf(false, true)
            local dim_win = vim.api.nvim_open_win(dim_buf, false, {
              relative = "editor",
              row = 0,
              col = 0,
              width = vim.o.columns,
              height = vim.o.lines,
              style = "minimal",
              zindex = 40,
            })
            vim.wo[dim_win].winhighlight = "Normal:YaziDim"
            vim.wo[dim_win].winblend = 20
            -- Store for cleanup
            vim.g.yazi_dim_win = dim_win
            vim.g.yazi_dim_buf = dim_buf
          end
        '';
        yazi_closed_successfully.__raw = ''
          function(chosen_file, config, state)
            -- Clean up dim overlay
            local dim_win = vim.g.yazi_dim_win
            if dim_win and vim.api.nvim_win_is_valid(dim_win) then
              vim.api.nvim_win_close(dim_win, true)
            end
            vim.g.yazi_dim_win = nil
            vim.g.yazi_dim_buf = nil
          end
        '';
      };
    };
  };

  keymaps = [
    {
      key = "<leader>fe";
      action = "<cmd>Yazi<cr>";
      mode = ["n" "v"];
      options.desc = "File explorer (yazi)";
    }
  ];

  # Disable netrw before plugins load (must be in extraConfigLuaPre)
  extraConfigLuaPre = ''
    vim.g.loaded_netrwPlugin = 1
  '';
}
