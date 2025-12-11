-- init.lua - Project picker using Snacks.nvim with caching
local M = {}

local finder = require("project-picker.finder")
local tmux = require("project-picker.tmux")

---@class ProjectPickerConfig
---@field directories string[] Root directories to search for projects
---@field max_depth number Maximum depth to search for projects
---@field start_nvim boolean Start neovim in new sessions
---@field cache_ttl number Cache time-to-live in seconds (0 to disable)

---@type ProjectPickerConfig
local default_config = {
  directories = { "~/projects", "~/code" },
  max_depth = 5,
  start_nvim = true,
  cache_ttl = 300, -- 5 minutes
}

---@type ProjectPickerConfig
M.config = vim.deepcopy(default_config)

-- Cache state
local cache = {
  projects = nil,
  timestamp = 0,
  refreshing = false,
}

--- Get cache file path
---@return string
local function get_cache_path()
  return vim.fn.stdpath("cache") .. "/project-picker-cache.json"
end

--- Load cache from disk
---@return table|nil
local function load_cache_from_disk()
  local path = get_cache_path()
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end

  local ok, content = pcall(vim.fn.readfile, path)
  if not ok or #content == 0 then
    return nil
  end

  local ok2, data = pcall(vim.json.decode, table.concat(content, "\n"))
  if not ok2 or type(data) ~= "table" then
    return nil
  end

  return data
end

--- Save cache to disk
---@param projects table[]
local function save_cache_to_disk(projects)
  local path = get_cache_path()
  local data = {
    version = 1,
    timestamp = os.time(),
    projects = projects,
  }

  local ok, json = pcall(vim.json.encode, data)
  if ok then
    vim.fn.writefile({ json }, path)
  end
end

--- Check if cache is valid
---@return boolean
local function is_cache_valid()
  if M.config.cache_ttl <= 0 then
    return false
  end
  if not cache.projects then
    return false
  end
  return (os.time() - cache.timestamp) < M.config.cache_ttl
end

--- Refresh projects (synchronous)
---@return table[]
local function refresh_projects_sync()
  local projects = finder.discover_all(M.config.directories, M.config.max_depth)
  cache.projects = projects
  cache.timestamp = os.time()
  save_cache_to_disk(projects)
  return projects
end

--- Refresh projects in background
---@param callback? fun(projects: table[])
local function refresh_projects_async(callback)
  if cache.refreshing then
    return
  end

  cache.refreshing = true

  vim.schedule(function()
    local projects = finder.discover_all(M.config.directories, M.config.max_depth)
    cache.projects = projects
    cache.timestamp = os.time()
    cache.refreshing = false
    save_cache_to_disk(projects)

    if callback then
      callback(projects)
    end
  end)
end

--- Get projects (from cache or fresh)
---@param force_refresh? boolean
---@return table[]
local function get_projects(force_refresh)
  -- Force refresh requested
  if force_refresh then
    return refresh_projects_sync()
  end

  -- Try memory cache first
  if is_cache_valid() then
    return cache.projects
  end

  -- Try disk cache
  local disk_cache = load_cache_from_disk()
  if disk_cache and disk_cache.projects then
    local age = os.time() - (disk_cache.timestamp or 0)
    if age < M.config.cache_ttl then
      cache.projects = disk_cache.projects
      cache.timestamp = disk_cache.timestamp
      return cache.projects
    end
  end

  -- No valid cache, refresh synchronously
  return refresh_projects_sync()
end

--- Setup the project picker
---@param opts? ProjectPickerConfig
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", default_config, opts or {})
end

--- Create picker items from projects with tmux session info
---@param projects table[] List of ProjectInfo
---@return table[] items Snacks picker items
local function create_picker_items(projects)
  local sessions = tmux.get_sessions()
  local current_session = tmux.get_current_session()
  local items = {}

  for _, project in ipairs(projects) do
    local session_name = tmux.path_to_session_name(project.path, project.name, project.branch)
    local session_info = sessions[session_name]
    local has_session = session_info ~= nil
    local is_current = session_name == current_session

    -- Determine icon and highlight based on session status
    local icon = "○ "  -- hollow circle (no session)
    local hl = ""
    if is_current then
      icon = "● "  -- filled circle (current session)
      hl = "SnacksPickerGitStatusAdded"  -- green
    elseif has_session then
      icon = "● "  -- filled circle (active session)
      hl = "SnacksPickerDirectory"  -- blue-ish
    end

    table.insert(items, {
      text = project.display,
      -- Data for sorting
      has_session = has_session,
      is_current = is_current,
      last_attached = session_info and session_info.last_attached or 0,
      -- Data for display/action
      project_path = project.path,
      project_name = project.name,
      session_name = session_name,
      branch = project.branch,
      icon = icon,
      hl = hl,
    })
  end

  -- Sort: HasSession first (by LastActive desc), then NoSession (alphabetically)
  table.sort(items, function(a, b)
    -- Current session always first
    if a.is_current and not b.is_current then return true end
    if not a.is_current and b.is_current then return false end

    -- Sessions before non-sessions
    if a.has_session and not b.has_session then return true end
    if not a.has_session and b.has_session then return false end

    -- Both have sessions: sort by last_attached (most recent first)
    if a.has_session and b.has_session then
      return a.last_attached > b.last_attached
    end

    -- Both no session: sort alphabetically
    return a.text:lower() < b.text:lower()
  end)

  -- Add idx and score for Snacks picker
  for i, item in ipairs(items) do
    item.idx = i
    item.score = i
  end

  return items
end

--- Open the project picker
---@param opts? { refresh?: boolean }
function M.pick(opts)
  opts = opts or {}

  local has_snacks, Snacks = pcall(require, "snacks")
  if not has_snacks then
    vim.notify("project-picker: snacks.nvim is required", vim.log.levels.ERROR)
    return
  end

  if not tmux.is_in_tmux() then
    vim.notify("project-picker: must be running inside tmux", vim.log.levels.WARN)
    return
  end

  if vim.fn.executable("fd") ~= 1 then
    vim.notify("project-picker: fd is required for project discovery", vim.log.levels.ERROR)
    return
  end

  -- Get projects (from cache or fresh)
  local projects = get_projects(opts.refresh)
  if #projects == 0 then
    vim.notify("project-picker: no projects found", vim.log.levels.WARN)
    return
  end

  local items = create_picker_items(projects)

  -- Calculate max width for padding
  local max_width = 0
  for _, item in ipairs(items) do
    if #item.text > max_width then
      max_width = #item.text
    end
  end
  local padding = max_width + 5

  Snacks.picker({
    title = "Projects",
    items = items,
    layout = { preset = "select" },
    format = function(item)
      local ret = {}
      -- Icon
      ret[#ret + 1] = { item.icon, item.hl }
      -- Project name with branch
      ret[#ret + 1] = { item.text, item.hl ~= "" and item.hl or nil }
      -- Padding
      ret[#ret + 1] = { string.rep(" ", padding - #item.text), virtual = true }
      -- Session indicator
      if item.is_current then
        ret[#ret + 1] = { "(current)", "Comment" }
      elseif item.has_session then
        ret[#ret + 1] = { "(active)", "Comment" }
      end
      return ret
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        tmux.open_project(item.project_path, item.session_name, M.config.start_nvim)
      end
    end,
    win = {
      input = {
        keys = {
          ["<C-r>"] = {
            function(picker)
              picker:close()
              vim.notify("project-picker: refreshing...", vim.log.levels.INFO)
              vim.schedule(function()
                M.pick({ refresh = true })
              end)
            end,
            mode = { "i", "n" },
            desc = "Refresh projects",
          },
        },
      },
    },
  })

  -- Trigger background refresh if cache is getting stale (but still valid)
  if cache.projects and not cache.refreshing then
    local age = os.time() - cache.timestamp
    if age > (M.config.cache_ttl / 2) then
      refresh_projects_async()
    end
  end
end

--- Force refresh the cache
function M.refresh()
  refresh_projects_sync()
  vim.notify("project-picker: cache refreshed", vim.log.levels.INFO)
end

--- Clear the cache
function M.clear_cache()
  cache.projects = nil
  cache.timestamp = 0
  local path = get_cache_path()
  if vim.fn.filereadable(path) == 1 then
    vim.fn.delete(path)
  end
  vim.notify("project-picker: cache cleared", vim.log.levels.INFO)
end

return M
