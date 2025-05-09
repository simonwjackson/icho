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
        section_separators = {
          left = " ";
          right = " ";
        };
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
          "overseer"
        ];
        lualine_c = [];
        lualine_x = [
          "diagnostics"
          {
            __unkeyed-1 = {
              __raw = ''
                  function()
                  vim.api.nvim_create_autocmd("User", {
                    pattern = "CodeCompanionChatModel",
                    callback = function(args)
                      if args.data.model == nil or vim.tbl_isempty(args.data) then
                        return
                      end

                      vim.g.llm_name = args.data.model
                    end,
                  })
                  if vim.g.llm_name == nil then
                    return ""
                  end
                  if vim.bo.filetype == "codecompanion" then
                    return string.format("%%#StatusLineLSP#[%s]", vim.g.llm_name)
                  else
                    return ""
                  end
                end
              '';
            };
          }
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

      winbar = {};
    };
  };
}

