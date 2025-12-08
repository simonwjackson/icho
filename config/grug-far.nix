{ ... }: {
  plugins.grug-far = {
    enable = true;
    settings = {
      transient = false;
      wrap = false;
    };
  };

  extraConfigLua = ''
    -- Grug-far toggle helper
    _G.grug_far_toggle = function(visual_selection)
      local grug = require('grug-far')

      -- Find existing grug-far buffer
      local grug_buf = nil
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].filetype == "grug-far" then
          grug_buf = buf
          break
        end
      end

      if grug_buf then
        -- Check if it's visible in a window
        local win = vim.fn.bufwinid(grug_buf)
        if win ~= -1 and not visual_selection then
          -- Visible and no selection - hide it
          vim.api.nvim_win_close(win, false)
        else
          -- Hidden or has selection - show it
          if win == -1 then
            vim.cmd("topleft 60vsplit")
            vim.api.nvim_win_set_buf(0, grug_buf)
          else
            vim.api.nvim_set_current_win(win)
          end
          -- Update search if we have a selection
          if visual_selection then
            grug.update_instance_prefills(grug_buf, { search = visual_selection }, false)
          end
        end
      else
        -- No instance - create new
        local opts = {
          windowCreationCommand = "topleft 60vsplit",
        }
        if visual_selection then
          opts.prefills = { search = visual_selection }
        end
        grug.open(opts)
      end
    end
  '';

  keymaps = [
    {
      key = "<leader>S";
      action.__raw = ''
        function()
          _G.grug_far_toggle()
        end
      '';
      options.desc = "Search and Replace";
    }
    {
      key = "<leader>S";
      mode = "v";
      action.__raw = ''
        function()
          local sel = require('grug-far').get_current_visual_selection()
          _G.grug_far_toggle(sel)
        end
      '';
      options.desc = "Search and Replace (selection)";
    }
  ];
}
