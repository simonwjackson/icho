{pkgs, ...}: {
  extraPackages = with pkgs; [
    tmux
  ];

  plugins.web-devicons.enable = true;

  plugins.lualine = {
    enable = true;
    settings = {
      options = {
        disabled_filetypes = {
          __unkeyed-1 = "startify";
          __unkeyed-2 = "neo-tree";
          statusline = [
            "dap-repl"
          ];
          winbar = [
            "aerial"
            "dap-repl"
            "neotest-summary"
          ];
        };
        globalstatus = true;
        component_separators = {
          left = "|";
          right = "|";
        };
      };
      sections = {
        lualine_a = [
          "mode"
        ];
        lualine_b = [
          "branch"
        ];
        lualine_c = [
        ];
        lualine_x = [
          "diagnostics"
        ];
        lualine_y = [
          {
            __unkeyed-1 = "aerial";
            colored = true;
            cond = {
              __raw = ''
                function()
                  local buf_size_limit = 1024 * 1024
                  if vim.api.nvim_buf_get_offset(0, vim.api.nvim_buf_line_count(0)) > buf_size_limit then
                    return false
                  end

                  return true
                end
              '';
            };
            dense = false;
            dense_sep = ".";
            depth = {
              __raw = "nil";
            };
            sep = " ) ";
          }
        ];
        lualine_z = [
          {
            __unkeyed-1 = "location";
          }
        ];
      };
      inactive_sections = {};
      tabline = {
        lualine_a = [
          {
            __unkeyed-1 = {
              __raw = ''
                function()
                  return vim.fn.hostname()
                end
              '';
            };
          }
        ];
        lualine_b = [
          {
            __unkeyed-1 = {
              __raw = ''
                function()
                  local tmux_session = os.getenv("TMUX_PANE")
                  if tmux_session then
                    -- Get tmux session name using tmux display-message
                    local handle = io.popen("tmux display-message -p '#S'")
                    if handle then
                      local session_name = handle:read("*a")
                      handle:close()
                      return session_name:gsub("^%s*(.-)%s*$", "%1")  -- trim whitespace
                    end
                  end
                  return ""
                end
              '';
            };
          }
        ];
        lualine_c = [
          {
            __unkeyed-1 = {
              __raw = ''
                function()
                  local wins = vim.api.nvim_tabpage_list_wins(0)
                  local win_info = {}
                  for _, win in ipairs(wins) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    local name = vim.api.nvim_buf_get_name(buf)
                    if name ~= "" then
                      table.insert(win_info, vim.fn.fnamemodify(name, ":t"))
                    end
                  end
                  return table.concat(win_info, " | ")
                end
              '';
            };
          }
        ];
        lualine_x = [];
        lualine_y = [];
        lualine_z = [
          {
            __unkeyed-1 = {
              __raw = ''
                function()
                  local tabs = {}
                  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
                    local tab_num = vim.api.nvim_tabpage_get_number(tabpage)
                    local tab_name = vim.t[tabpage].name
                    local is_current = tabpage == vim.api.nvim_get_current_tabpage()
                    local display = tab_name and string.format("%d:%s", tab_num, tab_name) or tostring(tab_num)
                    if is_current then
                      display = "[" .. display .. "]"
                    end
                    table.insert(tabs, display)
                  end
                return table.concat(tabs, " ")
                end
              '';
            };
          }
        ];
      };
      winbar = {};
    };
  };
}
