-- tmux.lua - Tmux session management utilities
local M = {}

---@param args string[]
---@return string stdout
---@return integer code
---@return string stderr
local function run(args)
  local obj = vim.system(args, { text = true }):wait()
  return obj.stdout or "", obj.code, obj.stderr or ""
end

---@param s string
---@return string
local function strip(s)
  return string.match(s, "^%s*(.-)%s*$") or ""
end

--- Check if we're running inside tmux
---@return boolean
function M.is_in_tmux()
  return os.getenv("TMUX") ~= nil
end

--- Check if tmux is running
---@return boolean
function M.is_tmux_running()
  local stdout, code, _ = run({ "pgrep", "tmux" })
  return code == 0 and stdout ~= ""
end

--- Get current tmux session name
---@return string|nil
function M.get_current_session()
  if not M.is_in_tmux() then
    return nil
  end
  local stdout, code, _ = run({ "tmux", "display-message", "-p", "#S" })
  if code ~= 0 then
    return nil
  end
  return strip(stdout)
end

--- Get all tmux sessions with their last activity timestamp
---@return table<string, {name: string, last_attached: number}>
function M.get_sessions()
  local sessions = {}
  local stdout, code, _ = run({ "tmux", "list-sessions", "-F", "#{session_name}:#{session_last_attached}" })
  if code ~= 0 then
    return sessions
  end

  for line in stdout:gmatch("[^\r\n]+") do
    local name, timestamp = line:match("^([^:]+):(%d+)$")
    if name then
      sessions[name] = {
        name = name,
        last_attached = tonumber(timestamp) or 0,
      }
    end
  end

  return sessions
end

--- Convert a project path to a valid tmux session name
--- Uses enough path components to be unique
---@param path string
---@param project_name string|nil Optional project name for bare worktrees
---@param branch string|nil Optional branch name
---@return string
function M.path_to_session_name(path, project_name, branch)
  -- Get path components for uniqueness
  -- e.g., /snowscape/code/github/simonwjackson/elevate/main
  -- becomes: simonwjackson_elevate_main (3 components)
  local parts = {}
  local p = path
  for _ = 1, 3 do
    local base = vim.fs.basename(p)
    if base and base ~= "" then
      table.insert(parts, 1, base)
    end
    p = vim.fn.fnamemodify(p, ":h")
    if p == "/" or p == "" then break end
  end

  local name = table.concat(parts, "_")

  -- Replace invalid tmux session name characters
  name = string.gsub(name, "%.", "_")
  name = string.gsub(name, "[^%w_-]", "_")
  -- Collapse multiple underscores
  name = string.gsub(name, "_+", "_")
  -- Remove leading/trailing underscores
  name = string.gsub(name, "^_+", "")
  name = string.gsub(name, "_+$", "")

  return name
end

--- Check if a tmux session exists
---@param session_name string
---@return boolean
function M.session_exists(session_name)
  local _, code, _ = run({ "tmux", "has-session", "-t=" .. session_name })
  return code == 0
end

--- Switch to or create a tmux session for a project
---@param project_path string
---@param session_name string
---@param start_nvim? boolean whether to start nvim in new sessions (default: true)
function M.open_project(project_path, session_name, start_nvim)
  if start_nvim == nil then
    start_nvim = true
  end

  local tmux_env = os.getenv("TMUX")
  local tmux_running = M.is_tmux_running()

  -- Case 1: Not in tmux and tmux not running - create and attach
  if not tmux_env and not tmux_running then
    local args = { "tmux", "new-session", "-s", session_name, "-c", project_path }
    if start_nvim then
      table.insert(args, "nvim")
    end
    run(args)
    return
  end

  -- Case 2: Session doesn't exist - create it (detached)
  if not M.session_exists(session_name) then
    local args = { "tmux", "new-session", "-d", "-s", session_name, "-c", project_path }
    if start_nvim then
      table.insert(args, "nvim")
    end
    run(args)
  end

  -- Case 3: Not in tmux but tmux is running - attach to session
  if not tmux_env then
    run({ "tmux", "attach", "-t", session_name })
    return
  end

  -- Case 4: In tmux - switch to session
  run({ "tmux", "switch-client", "-t", session_name })
end

return M
