-- Claude Instances: Multi-instance Claude Code management
-- Provides floating terminal instances with session persistence

local M = {}

-- Configuration (set via Nix)
M.config = {
  terminal_cmd = nil, -- Set by Nix
  float_width = 0.8,
  float_height = 0.8,
  border = "rounded",
  background = "#1a1b26",
}

-- Instance registry: { id = { terminal, cwd, created_at, args, session_id, last_title } }
local instances = {}
local instance_counter = 0

-- Get session directory (git root or cwd)
local function get_session_dir()
  local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
  if vim.v.shell_error ~= 0 then
    return vim.fn.getcwd()
  end
  return git_root
end

-- Save instances to file
local function save_instances()
  local instances_data = {}
  for id, data in pairs(instances) do
    table.insert(instances_data, {
      id = id,
      cwd = data.cwd,
      args = data.args or "",
      session_id = data.session_id,
      last_title = data.last_title,
    })
  end

  local file_path = get_session_dir() .. "/.claude-instances.json"
  if #instances_data > 0 then
    local file = io.open(file_path, "w")
    if file then
      file:write(vim.json.encode(instances_data))
      file:close()
    end
  else
    os.remove(file_path)
  end
end

-- Get Claude CLI command with args
local function get_claude_cmd(args)
  local cmd = M.config.terminal_cmd
  if args and args ~= "" then
    cmd = cmd .. " " .. args
  end
  return cmd
end

-- Get display name for an instance
local function get_display_name(id, data)
  -- Try live terminal title first
  if data.terminal and data.terminal.bufnr and vim.api.nvim_buf_is_valid(data.terminal.bufnr) then
    local title = vim.b[data.terminal.bufnr].term_title
    if title and title ~= "" and not title:match("^term://") then
      title = title:gsub("^Claude Code%s*[-–]?%s*", "")
      title = title:gsub("^claude%s*[-–]?%s*", "")
      if title ~= "" then
        return title
      end
    end
  end
  -- Fall back to stored last_title
  if data.last_title and data.last_title ~= "" then
    local title = data.last_title
    title = title:gsub("^Claude Code%s*[-–]?%s*", "")
    title = title:gsub("^claude%s*[-–]?%s*", "")
    if title ~= "" then
      return title
    end
  end
  return id
end

-- Generate UUID for session tracking
local function generate_uuid()
  local handle = io.popen("uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid")
  if handle then
    local uuid = handle:read("*a"):gsub("%s+", "")
    handle:close()
    return uuid
  end
  return string.format("%08x-%04x-%04x-%04x-%012x",
    math.random(0, 0xffffffff),
    math.random(0, 0xffff),
    math.random(0, 0x0fff) + 0x4000,
    math.random(0, 0x3fff) + 0x8000,
    math.random(0, 0xffffffffffff))
end

-- Spawn a new Claude instance
function M.spawn(opts)
  local Terminal = require("toggleterm.terminal").Terminal

  opts = opts or {}
  instance_counter = instance_counter + 1
  local id = opts.id or ("claude-" .. instance_counter)
  local cwd = opts.cwd or vim.fn.getcwd()
  local args = opts.args or ""

  local session_id = opts.session_id or generate_uuid()
  local is_restore = opts.session_id ~= nil

  local cmd_args
  if is_restore then
    cmd_args = "--resume " .. session_id
    if args ~= "" then cmd_args = cmd_args .. " " .. args end
  else
    cmd_args = "--session-id " .. session_id
    if args ~= "" then cmd_args = cmd_args .. " " .. args end
  end

  local term = Terminal:new({
    cmd = get_claude_cmd(cmd_args),
    dir = cwd,
    direction = "float",
    float_opts = {
      border = M.config.border,
      width = math.floor(vim.o.columns * M.config.float_width),
      height = math.floor(vim.o.lines * M.config.float_height),
      title = " Claude Code ",
      title_pos = "center",
    },
    hidden = false,
    on_open = function(t)
      vim.cmd("startinsert!")
      vim.wo.winhighlight = "Normal:TerminalBackground,NormalFloat:TerminalBackground"

      if t.bufnr then
        local instance_id = id
        vim.api.nvim_create_autocmd("TermRequest", {
          buffer = t.bufnr,
          callback = function()
            vim.defer_fn(function()
              if not vim.api.nvim_buf_is_valid(t.bufnr) then return end
              local title = vim.b[t.bufnr].term_title
              if title and title ~= "" and not title:match("^term://") then
                if instances[instance_id] then
                  instances[instance_id].last_title = title
                  save_instances()
                end
                if t.window and vim.api.nvim_win_is_valid(t.window) then
                  local display_title = title
                  if #display_title > 50 then
                    display_title = display_title:sub(1, 47) .. "..."
                  end
                  vim.api.nvim_win_set_config(t.window, {
                    title = " " .. display_title .. " ",
                    title_pos = "center",
                  })
                end
              end
            end, 50)
          end,
        })
      end
    end,
    on_exit = function()
      instances[id] = nil
    end,
  })

  instances[id] = {
    terminal = term,
    cwd = cwd,
    created_at = os.time(),
    args = args,
    session_id = session_id,
    last_title = opts.last_title,
  }

  term:open()

  if opts.prompt and opts.prompt ~= "" then
    vim.defer_fn(function()
      term:send(opts.prompt)
    end, 500)
  end

  return id
end

-- List all instances
function M.list()
  local result = {}
  for id, data in pairs(instances) do
    table.insert(result, {
      id = id,
      name = get_display_name(id, data),
      cwd = data.cwd,
      created_at = data.created_at,
      is_open = data.terminal:is_open(),
    })
  end
  table.sort(result, function(a, b)
    return a.created_at < b.created_at
  end)
  return result
end

-- Focus an instance
function M.focus(id)
  local data = instances[id]
  if data and data.terminal then
    data.terminal:open()
    vim.cmd("startinsert!")
    return true
  end
  return false
end

-- Close an instance
function M.close(id)
  local data = instances[id]
  if data and data.terminal then
    data.terminal:shutdown()
    instances[id] = nil
    return true
  end
  return false
end

-- Close all instances
function M.close_all()
  for id in pairs(instances) do
    M.close(id)
  end
end

-- Get current instance
function M.current()
  local current_buf = vim.api.nvim_get_current_buf()
  for id, data in pairs(instances) do
    if data.terminal.bufnr == current_buf then
      return id, data
    end
  end
  return nil, nil
end

-- Navigate instances
function M.navigate(direction)
  local list = M.list()
  if #list == 0 then
    vim.notify("No Claude instances", vim.log.levels.WARN)
    return
  end

  local current_id = M.current()
  local current_idx = 1

  if current_id then
    for i, inst in ipairs(list) do
      if inst.id == current_id then
        current_idx = i
        break
      end
    end
  end

  local next_idx
  if direction == "next" then
    next_idx = (current_idx % #list) + 1
  else
    next_idx = ((current_idx - 2) % #list) + 1
  end

  M.focus(list[next_idx].id)
end

-- Telescope picker
function M.pick()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local list = M.list()

  if #list == 0 then
    vim.notify("No Claude instances. Use <leader>an to create one.", vim.log.levels.INFO)
    return
  end

  pickers.new({}, {
    prompt_title = "Claude Instances",
    finder = finders.new_table({
      results = list,
      entry_maker = function(entry)
        local age = os.time() - entry.created_at
        local age_str
        if age < 60 then
          age_str = age .. "s"
        elseif age < 3600 then
          age_str = math.floor(age / 60) .. "m"
        else
          age_str = math.floor(age / 3600) .. "h"
        end

        local status = entry.is_open and "●" or "○"
        local display_name = entry.name
        if #display_name > 40 then
          display_name = display_name:sub(1, 37) .. "..."
        end
        local display = string.format("%s %-40s %s", status, display_name, age_str)

        return {
          value = entry,
          display = display,
          ordinal = entry.name .. " " .. entry.cwd,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection then
          M.focus(selection.value.id)
        end
      end)

      map("i", "<C-d>", function()
        local selection = action_state.get_selected_entry()
        if selection then
          M.close(selection.value.id)
          vim.notify("Closed " .. selection.value.name, vim.log.levels.INFO)
          actions.close(prompt_bufnr)
          vim.defer_fn(M.pick, 100)
        end
      end)

      map("i", "<C-n>", function()
        actions.close(prompt_bufnr)
        M.spawn()
      end)

      return true
    end,
  }):find()
end

-- Setup function
function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)

  -- Require toggleterm
  local ok, toggleterm = pcall(require, "toggleterm")
  if not ok then
    vim.notify("claude-instances: toggleterm.nvim is required", vim.log.levels.ERROR)
    return
  end

  toggleterm.setup({
    shade_terminals = false,
    float_opts = {
      border = M.config.border,
      winblend = 0,
    },
    highlights = {
      Normal = { link = "TerminalBackground" },
      NormalFloat = { link = "TerminalBackground" },
    },
  })

  -- Expose globals for resession integration
  _G.claude_save_instances = save_instances
  _G.claude_instances_registry = instances
  _G.claude_spawn_instance = M.spawn
end

-- Get display name (exported for external use)
M.get_display_name = get_display_name

return M
