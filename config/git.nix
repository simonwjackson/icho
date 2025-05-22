{pkgs, ...}: {
  extraPlugins = [
    pkgs.vimPlugins.advanced-git-search-nvim
    pkgs.vimPlugins.plenary-nvim # Required dependency
    pkgs.vimPlugins.telescope-nvim # For file selection
  ];

  plugins = {
    lazygit = {
      enable = true;
      settings.use_neovim_remote = 1;
    };
  };

  extraConfigLua = ''
    -- MiniDiff highlight improvements for better contrast

    vim.api.nvim_set_hl(0, 'DiffChange', { bg = '#4A4123', fg = '#F9E2AF' }) -- Dark yellow bg with yellow fg
    -- Advanced Git Search
    require('telescope').load_extension('advanced_git_search')

    -- Close DiffviewFilePanel with 'q'
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "DiffviewFiles",
      callback = function()
        vim.api.nvim_buf_set_keymap(0, 'n', 'q', ':DiffviewClose<CR>', { noremap = true, silent = true })
      end
    })

    -- Navigation functions for git hunks and LSP diagnostics
    function NavigateNext()
      local mini_diff_available, mini_diff = pcall(require, 'mini.diff')

      -- Try to navigate to next diagnostic first
      local diagnostics = vim.diagnostic.get(0)
      local current_line = vim.api.nvim_win_get_cursor(0)[1]

      for _, diagnostic in ipairs(diagnostics) do
        if diagnostic.lnum + 1 > current_line then
          vim.api.nvim_win_set_cursor(0, {diagnostic.lnum + 1, diagnostic.col})
          return
        end
      end

      -- If no more diagnostics, try git hunks
      if mini_diff_available then
        local hunks = mini_diff.get_buf_data().hunks
        if hunks then
          for _, hunk in ipairs(hunks) do
            if hunk.buf_start > current_line then
              vim.api.nvim_win_set_cursor(0, {hunk.buf_start, 0})
              return
            end
          end
        end
      end

      -- If no hunks forward, wrap to first diagnostic or hunk
      if #diagnostics > 0 then
        local first_diagnostic = diagnostics[1]
        vim.api.nvim_win_set_cursor(0, {first_diagnostic.lnum + 1, first_diagnostic.col})
      elseif mini_diff_available then
        local hunks = mini_diff.get_buf_data().hunks
        if hunks and #hunks > 0 then
          vim.api.nvim_win_set_cursor(0, {hunks[1].buf_start, 0})
        end
      end
    end

    function NavigatePrev()
      local mini_diff_available, mini_diff = pcall(require, 'mini.diff')

      -- Try to navigate to previous diagnostic first
      local diagnostics = vim.diagnostic.get(0)
      local current_line = vim.api.nvim_win_get_cursor(0)[1]

      -- Reverse iterate through diagnostics
      for i = #diagnostics, 1, -1 do
        local diagnostic = diagnostics[i]
        if diagnostic.lnum + 1 < current_line then
          vim.api.nvim_win_set_cursor(0, {diagnostic.lnum + 1, diagnostic.col})
          return
        end
      end

      -- If no more diagnostics, try git hunks
      if mini_diff_available then
        local hunks = mini_diff.get_buf_data().hunks
        if hunks then
          for i = #hunks, 1, -1 do
            local hunk = hunks[i]
            if hunk.buf_start < current_line then
              vim.api.nvim_win_set_cursor(0, {hunk.buf_start, 0})
              return
            end
          end
        end
      end

      -- If no hunks backward, wrap to last diagnostic or hunk
      if #diagnostics > 0 then
        local last_diagnostic = diagnostics[#diagnostics]
        vim.api.nvim_win_set_cursor(0, {last_diagnostic.lnum + 1, last_diagnostic.col})
      elseif mini_diff_available then
        local hunks = mini_diff.get_buf_data().hunks
        if hunks and #hunks > 0 then
          vim.api.nvim_win_set_cursor(0, {hunks[#hunks].buf_start, 0})
        end
      end
    end
  '';

  keymaps = [
    {
      key = "<leader>gg";
      action = "<cmd>LazyGit<CR>";
      options = {
        desc = "Git: LazyGit";
      };
    }
    {
      key = "<leader>gd";
      action = "<cmd>lua MiniDiff.toggle_overlay()<CR>";
      options = {
        desc = "Git: Search commit content";
      };
    }
    {
      key = "<leader>gw";
      action = "<cmd>Telescope advanced_git_search search_log_content<CR>";
      options = {
        desc = "Git: Search commit content";
      };
    }
    {
      key = "<Down>";
      action = "<cmd>lua NavigateNext()<CR>";
      options = {
        desc = "Navigate to next git hunk or LSP diagnostic";
      };
    }
    {
      key = "<Up>";
      action = "<cmd>lua NavigatePrev()<CR>";
      options = {
        desc = "Navigate to previous git hunk or LSP diagnostic";
      };
    }
  ];
}
