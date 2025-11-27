{pkgs, ...}: {
  extraPackages = [
    pkgs.bun
  ];

  # Add plugins
  extraPlugins = with pkgs; [
    vimPlugins.supermaven-nvim # AI code completion
    vimPlugins.claudecode-nvim
    vimPlugins.plenary-nvim # Required dependency
    vimPlugins.telescope-nvim # For file selection
  ];

  extraConfigLua = ''
    -- Skip supermaven in headless mode (e.g., nix flake check)
    -- supermaven tries to fetch a binary which fails in the sandbox
    if #vim.api.nvim_list_uis() > 0 then
      local ok, supermaven = pcall(require, "supermaven-nvim")
      if ok then
        supermaven.setup({
          keymaps = {
            accept_suggestion = "<Tab>",
            clear_suggestion = "<C-]>",
            accept_word = "<C-j>",
          },
          ignore_filetypes = { cpp = true }, -- or { "cpp", }
          log_level = "off", -- set to "off" to disable logging completely
          disable_inline_completion = false, -- disables inline completion for use with cmp
          disable_keymaps = false, -- disables built in keymaps for more manual control
          condition = function()
            return false
          end -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
        })

        -- Register supermaven as a cmp source (group 1 = highest priority)
        local cmp_ok, cmp = pcall(require, "cmp")
        if cmp_ok then
          local config = cmp.get_config()
          table.insert(config.sources, 1, { name = "supermaven", group_index = 1 })
          cmp.setup(config)
        end
      end

      -- claudecode.nvim setup (skip in headless mode)
      local claude_ok, claudecode = pcall(require, "claudecode")
      if claude_ok then
        claudecode.setup({
          auto_start = true,
          log_level = "info",
          terminal_cmd = "${pkgs.lib.getExe pkgs.bun} x @anthropic-ai/claude-code --dangerously-skip-permissions",
          terminal = {
            split_side = "right",
            split_width_percentage = 0.40,
            provider = "native",
            auto_close = true,
          },
          diff_opts = {
            auto_close_on_accept = true,
            vertical_split = true,
          },
        })

        -- Auto-reload buffers when files change on disk (for Claude Code edits)
        vim.o.autoread = true

        -- Timer-based file change detection
        local refresh_timer = vim.uv.new_timer()
        refresh_timer:start(0, 1000, vim.schedule_wrap(function()
          if vim.fn.getcmdwintype() == "" then
            vim.cmd("silent! checktime")
          end
        end))

        -- Also check on focus/buffer events
        vim.api.nvim_create_autocmd({"FocusGained", "BufEnter", "CursorHold"}, {
          group = vim.api.nvim_create_augroup("ClaudeCodeAutoReload", { clear = true }),
          callback = function()
            if vim.fn.getcmdwintype() == "" then
              vim.cmd("silent! checktime")
            end
          end,
        })

        -- Helper: find Claude Code terminal and send text
        local function send_to_claude_terminal(text)
          -- Find the Claude Code terminal buffer
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            local name = vim.api.nvim_buf_get_name(b)
            if name:match('claude') or name:match('ClaudeCode') then
              local chan = vim.bo[b].channel
              if chan and chan > 0 then
                -- Send text followed by Enter to submit
                vim.api.nvim_chan_send(chan, text .. '\n')
                -- Focus the terminal window if it exists
                for _, w in ipairs(vim.api.nvim_list_wins()) do
                  if vim.api.nvim_win_get_buf(w) == b then
                    vim.api.nvim_set_current_win(w)
                    break
                  end
                end
                return true
              end
            end
          end
          -- Fallback: check for any terminal with claude in job command
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.bo[b].buftype == 'terminal' then
              local chan = vim.bo[b].channel
              if chan and chan > 0 then
                local job_id = vim.b[b].terminal_job_id
                if job_id then
                  vim.api.nvim_chan_send(chan, text .. '\n')
                  for _, w in ipairs(vim.api.nvim_list_wins()) do
                    if vim.api.nvim_win_get_buf(w) == b then
                      vim.api.nvim_set_current_win(w)
                      break
                    end
                  end
                  return true
                end
              end
            end
          end
          return false
        end

        -- Compose prompt workflow: floating buffer with Supermaven completions
        vim.keymap.set('n', '<leader>ap', function()
          local buf = vim.api.nvim_create_buf(true, false) -- listed, not scratch
          vim.api.nvim_buf_set_name(buf, '/tmp/claude-compose-' .. os.time() .. '.md')
          vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
          vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
          vim.api.nvim_buf_set_option(buf, 'swapfile', false)

          local width = math.floor(vim.o.columns * 0.7)
          local height = math.floor(vim.o.lines * 0.5)
          local win = vim.api.nvim_open_win(buf, true, {
            relative = 'editor',
            width = width,
            height = height,
            col = math.floor((vim.o.columns - width) / 2),
            row = math.floor((vim.o.lines - height) / 2),
            style = 'minimal',
            border = 'rounded',
            title = ' Compose Prompt (Supermaven active) ',
            title_pos = 'center',
            footer = ' <C-CR> send | <Esc><Esc> cancel ',
            footer_pos = 'center',
          })

          -- Start in insert mode and trigger Supermaven
          vim.cmd('startinsert')

          -- Trigger Supermaven to attach to this buffer
          vim.schedule(function()
            local sm_ok, sm_api = pcall(require, 'supermaven-nvim.api')
            if sm_ok and sm_api.start then
              sm_api.start()
            end
          end)

          -- Send content to Claude and close
          local function send_and_close()
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            local content = table.concat(lines, '\n')
            if content:match('%S') then -- only send if non-empty
              vim.api.nvim_win_close(win, true)
              vim.schedule(function()
                -- Check if Claude is already connected
                local cc = require('claudecode')
                if cc.is_claude_connected() then
                  send_to_claude_terminal(content)
                else
                  -- Open Claude and poll until connected
                  vim.cmd('ClaudeCode')
                  local attempts = 0
                  local max_attempts = 100 -- 10 seconds max
                  local function try_send()
                    attempts = attempts + 1
                    if cc.is_claude_connected() then
                      -- Small extra delay for TUI to be fully ready
                      vim.defer_fn(function()
                        send_to_claude_terminal(content)
                      end, 200)
                    elseif attempts < max_attempts then
                      vim.defer_fn(try_send, 100)
                    else
                      vim.notify('Claude not connected after 10s', vim.log.levels.ERROR)
                    end
                  end
                  vim.defer_fn(try_send, 100)
                end
              end)
            else
              vim.notify('Empty prompt, not sending', vim.log.levels.WARN)
            end
          end

          -- Keybindings for the compose buffer
          local opts = { buffer = buf, noremap = true, silent = true }
          vim.keymap.set('n', '<C-CR>', send_and_close, opts)
          vim.keymap.set('i', '<C-CR>', send_and_close, opts)
          vim.keymap.set('n', '<Esc><Esc>', function()
            vim.api.nvim_win_close(win, true)
          end, opts)
        end, { desc = 'Claude Code: Compose prompt' })
      end
    end
  '';

  # Add convenient keymaps for Claude AI actions
  keymaps = [
    {
      key = "<leader>ai";
      action = "<cmd>silent! ClaudeCode<CR>";
      options = {
        desc = "Claude Code: Toggle";
      };
    }
    {
      key = "<leader>ac";
      action = "<cmd>silent! ClaudeCode --continue<CR>";
      options = {
        desc = "Claude Code: Continue";
      };
    }
    {
      key = "<leader>ar";
      action = "<cmd>silent! ClaudeCode --resume<CR>";
      options = {
        desc = "Claude Code: Resume";
      };
    }
    {
      key = "<leader>af";
      action = "<cmd>silent! ClaudeCodeAdd %<CR>";
      options = {
        desc = "Claude Code: Send file";
      };
    }
    {
      key = "<leader>av";
      action = "<cmd>silent! ClaudeCodeSend<CR>";
      mode = "v";
      options = {
        desc = "Claude Code: Send selection";
      };
    }
    {
      key = "<leader>aa";
      action = "<cmd>silent! ClaudeCodeDiffAccept<CR>";
      options = {
        desc = "Claude Code: Accept diff";
      };
    }
    {
      key = "<leader>ad";
      action = "<cmd>silent! ClaudeCodeDiffDeny<CR>";
      options = {
        desc = "Claude Code: Deny diff";
      };
    }
    {
      key = "<leader>ae";
      action = "<cmd>lua vim.g.claude_yazi_mode = true; require('yazi').yazi()<CR>";
      options = {
        desc = "Claude Code: Add files (yazi)";
      };
    }
  ];
}
