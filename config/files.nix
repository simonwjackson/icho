{pkgs, ...}: {
  plugins = {
    telescope = {
      enable = true;
    };

    yazi = {
      enable = true;
      settings = {
        floating_window_scaling_factor = 0.618;
        hooks = {
          yazi_opened_multiple_files.__raw = ''
            function(chosen_files, config, state)
              if vim.g.claude_yazi_mode then
                vim.g.claude_yazi_mode = false
                local should_compose = vim.g.claude_compose_after_yazi
                vim.g.claude_compose_after_yazi = false
                if should_compose and vim.g.claude_open_compose_prompt then
                  -- Open scratchpad with selected files shown
                  vim.schedule(function()
                    vim.g.claude_open_compose_prompt({ files = chosen_files })
                  end)
                else
                  -- Just add files directly (original <leader>ae behavior)
                  for _, file in ipairs(chosen_files) do
                    vim.cmd("ClaudeCodeAdd " .. vim.fn.fnameescape(file))
                  end
                  vim.notify("Added " .. #chosen_files .. " file(s) to Claude", vim.log.levels.INFO)
                end
              else
                -- Default: open in quickfix
                local items = {}
                for _, file in ipairs(chosen_files) do
                  table.insert(items, { filename = file, text = file })
                end
                vim.fn.setqflist(items)
                vim.cmd("copen")
              end
            end
          '';
        };
      };
    };
  };

  extraPackages = [
    pkgs.neovim-remote
  ];

  extraConfigLua = ''
    -- Advanced Git Search
    require('telescope').load_extension('advanced_git_search')

    -- Close DiffviewFilePanel with 'q'
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "DiffviewFiles",
      callback = function()
        vim.api.nvim_buf_set_keymap(0, 'n', 'q', ':DiffviewClose<CR>', { noremap = true, silent = true })
      end
    })

    local fn = vim.fn
    local o = vim.o

  '';

  keymaps = [
    {
      key = "<leader>fe";
      action = "<cmd>Yazi<CR>";
      options = {
        desc = "Open yazi at the current file";
      };
    }
    {
      key = "<leader>ff";
      action = "<cmd> Telescope find_files <CR>";
      options = {
        desc = "Find files";
      };
    }

    {
      key = "<leader>fF";
      action = "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>";
      options = {
        desc = "Find all files";
      };
    }

    {
      key = "<leader>fw";
      action = "<cmd> Telescope live_grep <CR>";
      options = {
        desc = "Live grep";
      };
    }

    {
      key = "<leader>fo";
      action = "<cmd> Telescope oldfiles <CR>";
      options = {
        desc = "Find oldfiles";
      };
    }
  ];
}
