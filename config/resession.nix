{ pkgs, resession-nvim, ... }:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "resession-nvim";
      src = resession-nvim;
      doCheck = false;
    })
  ];

  extraConfigLua = ''
    local resession = require("resession")

    -- Get session directory (git root, worktree, or cwd)
    local function get_session_dir()
      local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
      if vim.v.shell_error ~= 0 then
        return vim.fn.getcwd()
      end

      local git_dir = vim.fn.system("git rev-parse --git-dir 2>/dev/null"):gsub("\n", "")
      if vim.v.shell_error == 0 and git_dir:match("%.git/worktrees/") then
        return vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
      end

      return git_root
    end

    local function get_session_file()
      return get_session_dir() .. "/.resession.json"
    end

    resession.setup({
      autosave = { enabled = false },
      buf_filter = resession.default_buf_filter,
      extensions = { quickfix = {} },
    })

    -- Convert paths in window layouts
    local function convert_winlayout_paths(layout, base_dir, to_relative)
      if type(layout) ~= "table" then return layout end

      if layout[1] == "leaf" and layout[2] and layout[2].bufname then
        if to_relative then
          if vim.startswith(layout[2].bufname, base_dir) then
            layout[2].bufname = layout[2].bufname:sub(#base_dir + 2)
          end
        else
          if not vim.startswith(layout[2].bufname, "/") and not vim.startswith(layout[2].bufname, "~") then
            layout[2].bufname = base_dir .. "/" .. layout[2].bufname
          end
        end
      elseif (layout[1] == "row" or layout[1] == "col") and layout[2] then
        for _, child in ipairs(layout[2]) do
          convert_winlayout_paths(child, base_dir, to_relative)
        end
      end

      return layout
    end

    -- Convert absolute paths to relative
    local function make_paths_relative(content, base_dir)
      local data = vim.json.decode(content)

      if data.buffers then
        for _, buffer in ipairs(data.buffers) do
          if buffer.name and buffer.name ~= "" and vim.startswith(buffer.name, base_dir) then
            buffer.name = buffer.name:sub(#base_dir + 2)
          end
        end
      end

      if data.global and data.global.cwd and vim.startswith(data.global.cwd, base_dir) then
        data.global.cwd = "."
      end

      if data.tabs then
        for _, tab in ipairs(data.tabs) do
          if tab.cwd and vim.startswith(tab.cwd, base_dir) then
            tab.cwd = "."
          end
          if tab.wins then
            convert_winlayout_paths(tab.wins, base_dir, true)
          end
        end
      end

      return vim.json.encode(data)
    end

    -- Convert relative paths to absolute
    local function make_paths_absolute(content, base_dir)
      local data = vim.json.decode(content)

      if data.buffers then
        for _, buffer in ipairs(data.buffers) do
          if buffer.name and buffer.name ~= "" then
            if not vim.startswith(buffer.name, "/") and not vim.startswith(buffer.name, "~") then
              buffer.name = base_dir .. "/" .. buffer.name
            end
          end
        end
      end

      if data.global and data.global.cwd and data.global.cwd == "." then
        data.global.cwd = base_dir
      end

      if data.tabs then
        for _, tab in ipairs(data.tabs) do
          if tab.cwd and tab.cwd == "." then
            tab.cwd = base_dir
          end
          if tab.wins then
            convert_winlayout_paths(tab.wins, base_dir, false)
          end
        end
      end

      return vim.json.encode(data)
    end

    -- Save session to project root with relative paths
    local function save_to_project_root()
      resession.save("temp_session", { notify = false, attach = false })

      local session_file = vim.fn.stdpath("data") .. "/session/temp_session.json"
      local target_file = get_session_file()
      local base_dir = get_session_dir()

      local file = io.open(session_file, "r")
      if file then
        local content = file:read("*all")
        file:close()

        content = make_paths_relative(content, base_dir)

        local target = io.open(target_file, "w")
        if target then
          target:write(content)
          target:close()
        end

        os.remove(session_file)
      end
    end

    -- Load session from project root, converting to absolute paths
    local function load_from_project_root()
      local session_file = get_session_file()
      local base_dir = get_session_dir()

      local file = io.open(session_file, "r")
      if not file then return false end
      file:close()

      local temp_session = vim.fn.stdpath("data") .. "/session/temp_session.json"
      vim.fn.mkdir(vim.fn.stdpath("data") .. "/session", "p")

      local source = io.open(session_file, "r")
      if source then
        local content = source:read("*all")
        source:close()

        content = make_paths_absolute(content, base_dir)

        local target = io.open(temp_session, "w")
        if target then
          target:write(content)
          target:close()

          resession.load("temp_session", { silence_errors = true })
          os.remove(temp_session)
          return true
        end
      end
      return false
    end

    -- Auto-save on exit
    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = vim.api.nvim_create_augroup("ResessionAutoSave", { clear = true }),
      callback = save_to_project_root,
    })

    -- Auto-load on startup (if no files specified)
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("ResessionAutoLoad", { clear = true }),
      callback = function()
        if vim.fn.argc(-1) == 0 then
          load_from_project_root()
        end
      end,
      nested = true,
    })
  '';
}
