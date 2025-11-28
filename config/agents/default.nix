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
        -- Shared background for compose prompt and terminals
        vim.api.nvim_set_hl(0, "TerminalBackground", { bg = "#1a1b26" })

        -- Apply background to all terminal windows
        vim.api.nvim_create_autocmd("TermOpen", {
          group = vim.api.nvim_create_augroup("TerminalBackgroundGroup", { clear = true }),
          callback = function()
            vim.wo.winhighlight = "Normal:TerminalBackground,NormalFloat:TerminalBackground"
          end,
        })
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

        -- Slash command cache for completions
        vim.g.claude_commands_cache = {}
        vim.g.claude_commands_last_fetch = 0
        vim.g.claude_commands_ttl = 300 -- 5 minutes
        vim.g.claude_commands_loading = false

        -- Fetch slash commands from Claude CLI in background
        local function fetch_claude_commands(callback)
          vim.g.claude_commands_loading = true
          local cmd = {"sh", "-c", "${pkgs.lib.getExe pkgs.bun} x @anthropic-ai/claude-code -p x --output-format json --tools= --verbose 2>&1"}
          vim.system(cmd, { text = true }, function(obj)
            vim.schedule(function()
              vim.g.claude_commands_loading = false

              -- Check for non-zero exit code
              if obj.code ~= 0 then
                -- Silent fail, keep existing cache
                if callback then callback(nil) end
                return
              end

              local output = obj.stdout or ""
              local json_start = output:find("%[{")
              if not json_start then
                -- No init message found, keep stale cache
                if callback then callback(nil) end
                return
              end

              local json_str = output:sub(json_start)
              local ok, messages = pcall(vim.json.decode, json_str)
              if ok and type(messages) == "table" then
                for _, msg in ipairs(messages) do
                  if msg.subtype == "init" and msg.slash_commands then
                    vim.g.claude_commands_cache = msg.slash_commands
                    vim.g.claude_commands_last_fetch = os.time()
                    if callback then callback(msg.slash_commands) end
                    return
                  end
                end
              end

              -- No init message found in parsed JSON
              if callback then callback(nil) end
            end)
          end)
        end

        -- Check if cache is stale
        local function is_cache_stale()
          return os.time() - vim.g.claude_commands_last_fetch > vim.g.claude_commands_ttl
        end

        -- Refresh cache if stale (non-blocking)
        local function refresh_if_stale(callback)
          if is_cache_stale() then
            fetch_claude_commands(callback)
          elseif callback then
            callback(vim.g.claude_commands_cache)
          end
        end

        -- Initial fetch on startup (delayed to not block)
        vim.defer_fn(function()
          fetch_claude_commands()
        end, 2000)

        -- Refresh cache on directory change
        vim.api.nvim_create_autocmd("DirChanged", {
          callback = function()
            fetch_claude_commands()
          end,
        })

        -- Persistent compose buffer (declared early for cmp source access)
        local compose_buf = nil

        -- nvim-cmp source for Claude slash commands (only in scratchpad)
        local claude_commands_source = {}

        claude_commands_source.new = function()
          return setmetatable({}, { __index = claude_commands_source })
        end

        claude_commands_source.is_available = function()
          -- Only available in the compose scratchpad buffer
          if not compose_buf or vim.api.nvim_get_current_buf() ~= compose_buf then
            return false
          end
          -- Only trigger if / is at the start of the buffer
          local cursor = vim.api.nvim_win_get_cursor(0)
          local row, col = cursor[1], cursor[2]
          -- Must be on first line, first character position
          return row == 1 and col <= 1
        end

        claude_commands_source.get_trigger_characters = function()
          return { "/" }
        end

        claude_commands_source.get_keyword_pattern = function()
          return [[\%(/\w*\)]]
        end

        claude_commands_source.complete = function(self, params, callback)
          local items = {}
          local commands = vim.g.claude_commands_cache or {}

          for _, cmd in ipairs(commands) do
            table.insert(items, {
              label = "/" .. cmd,
              kind = require("cmp").lsp.CompletionItemKind.Function,
              insertText = "/" .. cmd,
            })
          end

          callback({ items = items, isIncomplete = false })
        end

        -- Register the source globally (is_available restricts to scratchpad)
        local cmp_ok, cmp = pcall(require, "cmp")
        if cmp_ok then
          cmp.register_source("claude_commands", claude_commands_source.new())
        end

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

        -- Helper: send content to Claude (handles connection)
        local function send_content_to_claude(content)
          local cc = require('claudecode')
          if cc.is_claude_connected() then
            send_to_claude_terminal(content)
          else
            vim.cmd('ClaudeCode')
            local attempts = 0
            local max_attempts = 100
            local function try_send()
              attempts = attempts + 1
              if cc.is_claude_connected() then
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
        end

        -- Compose prompt workflow: floating buffer with Supermaven completions
        -- opts.files: list of file paths to show and add before sending
        -- opts.initial_lines: custom initial content as a table of lines
        local function open_compose_prompt(opts)
          opts = opts or {}
          refresh_if_stale()

          -- Reuse existing buffer or create new one
          if not compose_buf or not vim.api.nvim_buf_is_valid(compose_buf) then
            compose_buf = vim.api.nvim_create_buf(true, true)
            vim.api.nvim_buf_set_option(compose_buf, "bufhidden", "hide")
            vim.api.nvim_buf_set_option(compose_buf, "filetype", "markdown")
            vim.api.nvim_buf_set_option(compose_buf, "swapfile", false)
            vim.api.nvim_buf_set_option(compose_buf, "buftype", "nofile")

          end

          local buf = compose_buf

          -- Append content if provided (don't replace existing)
          local current_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          local has_content = #current_lines > 1 or (current_lines[1] and current_lines[1] ~= "")

          if opts.initial_lines then
            if has_content then
              -- Append to existing content
              table.insert(current_lines, "")
              for _, line in ipairs(opts.initial_lines) do
                table.insert(current_lines, line)
              end
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, current_lines)
            else
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, opts.initial_lines)
            end
          elseif opts.files and #opts.files > 0 then
            local new_lines = {}
            for _, file in ipairs(opts.files) do
              table.insert(new_lines, "@" .. file)
            end
            table.insert(new_lines, "")
            table.insert(new_lines, "")
            if has_content then
              table.insert(current_lines, "")
              for _, line in ipairs(new_lines) do
                table.insert(current_lines, line)
              end
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, current_lines)
            else
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
            end
          end

          local width = math.floor(vim.o.columns * 0.7)
          local height = math.floor(vim.o.lines * 0.5)
          local win = vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            width = width,
            height = height,
            col = math.floor((vim.o.columns - width) / 2),
            row = math.floor((vim.o.lines - height) / 2),
            style = "minimal",
            border = "rounded",
            title = " Compose Prompt (Supermaven active) ",
            title_pos = "center",
            footer = " <C-s> send | <Esc><Esc> cancel ",
            footer_pos = "center",
          })

          -- Apply shared background
          vim.wo[win].winhighlight = "Normal:TerminalBackground,NormalFloat:TerminalBackground"

          -- Move cursor to end and start insert
          local line_count = vim.api.nvim_buf_line_count(buf)
          vim.api.nvim_win_set_cursor(win, { line_count, 0 })
          vim.cmd("startinsert")

          vim.schedule(function()
            local sm_ok, sm_api = pcall(require, "supermaven-nvim.api")
            if sm_ok and sm_api.start then
              sm_api.start()
            end
          end)

          local function send_and_close()
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            local content = table.concat(lines, "\n")
            if content:match("%S") then
              vim.api.nvim_win_close(win, true)
              -- Clear buffer after sending
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, {""})
              vim.schedule(function()
                -- Add files to Claude context first
                if opts.files then
                  for _, file in ipairs(opts.files) do
                    vim.cmd("silent! ClaudeCodeAdd " .. vim.fn.fnameescape(file))
                  end
                end
                vim.defer_fn(function()
                  send_content_to_claude(content)
                end, opts.files and #opts.files > 0 and 100 or 0)
              end)
            else
              vim.notify("Empty prompt, not sending", vim.log.levels.WARN)
            end
          end

          local buf_opts = { buffer = buf, noremap = true, silent = true }
          vim.keymap.set("n", "<C-s>", send_and_close, buf_opts)
          vim.keymap.set("i", "<C-s>", send_and_close, buf_opts)
          vim.keymap.set("n", "<Esc><Esc>", function()
            vim.api.nvim_win_close(win, true)
          end, buf_opts)
        end

        -- Expose for yazi hook
        vim.g.claude_open_compose_prompt = open_compose_prompt
        vim.g.claude_send_content = send_content_to_claude

        -- Manual refresh slash commands cache
        vim.keymap.set("n", "<leader>a?", function()
          if vim.g.claude_commands_loading then
            vim.notify("Already refreshing...", vim.log.levels.WARN)
            return
          end
          vim.notify("Refreshing Claude commands...", vim.log.levels.INFO)
          fetch_claude_commands(function(commands)
            if commands and #commands > 0 then
              vim.notify("Loaded " .. #commands .. " commands", vim.log.levels.INFO)
            else
              vim.notify("Failed to load commands", vim.log.levels.WARN)
            end
          end)
        end, { desc = "Claude Code: Refresh commands" })

        vim.keymap.set('n', '<leader>ap', function() open_compose_prompt() end, { desc = 'Claude Code: Compose prompt' })

        -- Smart open/focus Claude Code (not toggle)
        vim.keymap.set('n', '<leader>ai', function()
          -- Find Claude terminal window
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local name = vim.api.nvim_buf_get_name(buf)
            if name:match("claude") or name:match("ClaudeCode") or vim.bo[buf].buftype == "terminal" then
              local chan = vim.bo[buf].channel
              if chan and chan > 0 then
                -- Claude window found, focus it
                vim.api.nvim_set_current_win(win)
                vim.cmd("startinsert")
                return
              end
            end
          end
          -- Not found, open it
          vim.cmd("silent! ClaudeCode")
        end, { desc = "Claude Code: Open/Focus" })

        -- Scratchpad shortcut
        vim.keymap.set('n', '<leader>aI', function() open_compose_prompt() end, { desc = 'Claude Code: Scratchpad' })

        -- Compose with current file shown in scratchpad
        vim.keymap.set('n', '<leader>aF', function()
          local file = vim.fn.expand('%:p')
          open_compose_prompt({ files = { file } })
        end, { desc = 'Claude Code: Compose + send file' })

        -- Select files via yazi, then compose with them shown in scratchpad
        vim.keymap.set('n', '<leader>aE', function()
          vim.g.claude_yazi_mode = true
          vim.g.claude_compose_after_yazi = true
          require('yazi').yazi()
        end, { desc = 'Claude Code: Add files (yazi) + compose' })

        -- Compose with visual selection shown in scratchpad
        vim.keymap.set("v", "<leader>aV", function()
          -- Get visual selection
          vim.cmd('normal! "vy')
          local selection = vim.fn.getreg("v")
          local file = vim.fn.expand("%:p")
          local backticks = string.rep("`", 3)
          local initial_lines = { "@" .. file, "", backticks }
          for line in selection:gmatch("[^\n]+") do
            table.insert(initial_lines, line)
          end
          table.insert(initial_lines, backticks)
          table.insert(initial_lines, "")
          table.insert(initial_lines, "")
          open_compose_prompt({ initial_lines = initial_lines })
        end, { desc = "Claude Code: Selection + compose" })

        -- Helper: get unique files from grep results
        local function get_unique_files(selections)
          local files = {}
          local seen = {}
          for _, entry in ipairs(selections) do
            local file = entry.filename or entry.path
            if file and not seen[file] then
              seen[file] = true
              table.insert(files, file)
            end
          end
          return files
        end

        -- Telescope grep -> send to Claude
        vim.keymap.set("n", "<leader>aw", function()
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")
          require("telescope.builtin").live_grep({
            attach_mappings = function(prompt_bufnr, map)
              local function send_to_claude()
                local picker = action_state.get_current_picker(prompt_bufnr)
                local selections = picker:get_multi_selection()
                if #selections == 0 then
                  local entry = action_state.get_selected_entry()
                  if entry then selections = { entry } end
                end
                actions.close(prompt_bufnr)
                if #selections > 0 then
                  local files = get_unique_files(selections)
                  for _, file in ipairs(files) do
                    vim.cmd("silent! ClaudeCodeAdd " .. vim.fn.fnameescape(file))
                  end
                  vim.notify("Added " .. #files .. " file(s) to Claude", vim.log.levels.INFO)
                end
              end
              map("i", "<CR>", send_to_claude)
              map("n", "<CR>", send_to_claude)
              return true
            end,
          })
        end, { desc = "Claude Code: Grep + send" })

        -- Telescope grep -> scratchpad
        vim.keymap.set("n", "<leader>aW", function()
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")
          require("telescope.builtin").live_grep({
            attach_mappings = function(prompt_bufnr, map)
              local function send_to_scratchpad()
                local picker = action_state.get_current_picker(prompt_bufnr)
                local selections = picker:get_multi_selection()
                if #selections == 0 then
                  local entry = action_state.get_selected_entry()
                  if entry then selections = { entry } end
                end
                actions.close(prompt_bufnr)
                if #selections > 0 then
                  local files = get_unique_files(selections)
                  open_compose_prompt({ files = files })
                end
              end
              map("i", "<CR>", send_to_scratchpad)
              map("n", "<CR>", send_to_scratchpad)
              return true
            end,
          })
        end, { desc = "Claude Code: Grep + compose" })
      end
    end
  '';

  # Add convenient keymaps for Claude AI actions
  keymaps = [
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
      key = "<leader>at";
      action = "<cmd>silent! ClaudeCode<CR>";
      options = {
        desc = "Claude Code: Toggle";
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
