-- finder.lua - Project discovery using fd for fast scanning
local M = {}

---@class ProjectInfo
---@field path string Absolute path to the project/worktree
---@field name string Display name (project folder name, not worktree folder)
---@field branch string|nil Git branch name
---@field display string Display text: "Project Name [branch]"
---@field is_worktree boolean Whether this is a worktree of a bare repo

---@param cmd string[]
---@param cwd? string
---@return string stdout
---@return integer code
local function run_cmd(cmd, cwd)
  local opts = { text = true }
  if cwd then
    opts.cwd = cwd
  end
  local obj = vim.system(cmd, opts):wait()
  return obj.stdout or "", obj.code
end

---@param s string
---@return string
local function strip(s)
  return string.match(s, "^%s*(.-)%s*$") or ""
end

--- Get the parent directory of a path
---@param path string
---@return string
local function parent_dir(path)
  return vim.fn.fnamemodify(path, ":h")
end

--- Get git branch for a standard repo
---@param repo_path string
---@return string|nil
local function get_branch(repo_path)
  local stdout, code = run_cmd({ "git", "-C", repo_path, "branch", "--show-current" })
  if code ~= 0 then
    return nil
  end
  local branch = strip(stdout)
  return branch ~= "" and branch or nil
end

--- Get worktrees from a bare repository
---@param bare_dir string Path to the .bare directory
--- Resolve path to canonical form (follows symlinks, removes . and ..)
---@param path string
---@return string|nil
local function resolve_path(path)
  local resolved = vim.fn.resolve(path)
  if vim.fn.isdirectory(resolved) == 1 then
    return resolved
  end
  return nil
end

---@return ProjectInfo[]
local function get_worktrees_from_bare(bare_dir)
  local worktrees = {}
  local project_root = parent_dir(bare_dir)
  local project_name = vim.fn.fnamemodify(project_root, ":t")

  local stdout, code = run_cmd({ "git", "--git-dir=" .. bare_dir, "worktree", "list", "--porcelain" })
  if code ~= 0 then
    return worktrees
  end

  local current_path = nil
  local current_branch = nil

  for line in stdout:gmatch("[^\r\n]+") do
    local worktree_path = line:match("^worktree (.+)$")
    local branch = line:match("^branch refs/heads/(.+)$")
    local is_bare = line:match("^bare$")

    if worktree_path then
      -- Save previous worktree if exists, not bare, and path exists
      if current_path and current_path ~= bare_dir then
        local resolved = resolve_path(current_path)
        if resolved then
          local display = current_branch and (project_name .. " [" .. current_branch .. "]") or project_name
          table.insert(worktrees, {
            path = resolved,
            name = project_name,
            branch = current_branch,
            display = display,
            is_worktree = true,
          })
        end
      end
      current_path = worktree_path
      current_branch = nil
    elseif branch and current_path then
      current_branch = branch
    elseif is_bare then
      -- Skip bare worktree entry
      current_path = nil
      current_branch = nil
    end
  end

  -- Don't forget the last worktree
  if current_path and current_path ~= bare_dir then
    local resolved = resolve_path(current_path)
    if resolved then
      local display = current_branch and (project_name .. " [" .. current_branch .. "]") or project_name
      table.insert(worktrees, {
        path = resolved,
        name = project_name,
        branch = current_branch,
        display = display,
        is_worktree = true,
      })
    end
  end

  return worktrees
end

--- Find all .git directories using fd
---@param root_dirs string[]
---@param max_depth number
---@return string[] paths to .git directories
local function find_git_dirs(root_dirs, max_depth)
  local results = {}

  for _, root in ipairs(root_dirs) do
    root = vim.fn.expand(root)
    if vim.fn.isdirectory(root) == 1 then
      local stdout, code = run_cmd({
        "fd", "-H", "-t", "d", "^\\.git$",
        "--max-depth", tostring(max_depth),
        "--no-ignore",
        root
      })
      if code == 0 and stdout ~= "" then
        for line in stdout:gmatch("[^\r\n]+") do
          line = strip(line)
          -- Remove trailing slash if present
          if vim.endswith(line, "/") then
            line = line:sub(1, -2)
          end
          if line ~= "" then
            table.insert(results, line)
          end
        end
      end
    end
  end

  return results
end

--- Find all .bare directories using fd
---@param root_dirs string[]
---@param max_depth number
---@return string[] paths to .bare directories
local function find_bare_dirs(root_dirs, max_depth)
  local results = {}

  for _, root in ipairs(root_dirs) do
    root = vim.fn.expand(root)
    if vim.fn.isdirectory(root) == 1 then
      local stdout, code = run_cmd({
        "fd", "-H", "-t", "d", "^\\.bare$",
        "--max-depth", tostring(max_depth),
        "--no-ignore",
        root
      })
      if code == 0 and stdout ~= "" then
        for line in stdout:gmatch("[^\r\n]+") do
          line = strip(line)
          -- Remove trailing slash if present
          if vim.endswith(line, "/") then
            line = line:sub(1, -2)
          end
          if line ~= "" then
            table.insert(results, line)
          end
        end
      end
    end
  end

  return results
end

--- Discover all projects from root directories
---@param root_dirs string[]
---@param max_depth number
---@return ProjectInfo[]
function M.discover_all(root_dirs, max_depth)
  local projects = {}
  local seen_paths = {}

  -- Track bare repo roots so we don't add them as standard repos
  local bare_roots = {}

  -- First, find and process bare repos (they take precedence)
  local bare_dirs = find_bare_dirs(root_dirs, max_depth)
  for _, bare_dir in ipairs(bare_dirs) do
    local project_root = parent_dir(bare_dir)
    bare_roots[project_root] = true

    local worktrees = get_worktrees_from_bare(bare_dir)
    for _, wt in ipairs(worktrees) do
      if not seen_paths[wt.path] then
        seen_paths[wt.path] = true
        table.insert(projects, wt)
      end
    end
  end

  -- Then, find standard git repos (skip if inside a bare repo root)
  local git_dirs = find_git_dirs(root_dirs, max_depth)
  for _, git_dir in ipairs(git_dirs) do
    local repo_path = parent_dir(git_dir)

    -- Skip if this is inside a bare repo structure
    local is_inside_bare = false
    for bare_root, _ in pairs(bare_roots) do
      if vim.startswith(repo_path, bare_root .. "/") or repo_path == bare_root then
        is_inside_bare = true
        break
      end
    end

    if not is_inside_bare and not seen_paths[repo_path] then
      seen_paths[repo_path] = true
      local name = vim.fn.fnamemodify(repo_path, ":t")
      local branch = get_branch(repo_path)
      local display = branch and (name .. " [" .. branch .. "]") or name

      table.insert(projects, {
        path = repo_path,
        name = name,
        branch = branch,
        display = display,
        is_worktree = false,
      })
    end
  end

  return projects
end

return M
