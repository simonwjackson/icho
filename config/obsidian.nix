{lib, ...}: {
  plugins.obsidian = {
    enable = true;
    lazyLoad = {
      enable = true;
      settings = {
        ft = ["markdown"];
        cmd = [
          "Obsidian"
          "ObsidianNew"
          "ObsidianQuickSwitch"
          "ObsidianSearch"
          "ObsidianToday"
          "ObsidianYesterday"
          "ObsidianBacklinks"
          "ObsidianLinks"
          "ObsidianTags"
          "ObsidianRename"
          "ObsidianPasteImg"
          "ObsidianExtractNote"
          "ObsidianLink"
          "ObsidianLinkNew"
        ];
      };
    };
    settings = {
      workspaces = [
        {
          name = "knowledge";
          path = "/snowscape/knowledge";
        }
      ];

      detect_cwd = true;
      notes_subdir = "notes";
      new_notes_location = "notes_subdir";
      preferred_link_style = "markdown";
      legacy_commands = false;

      daily_notes = {
        folder = "daily";
        date_format = "%Y-%m-%d";
        alias_format = "%B %-d, %Y";
      };

      templates = {
        folder = "templates";
        date_format = "%Y-%m-%d";
        time_format = "%H:%M";
      };

      completion = {
        nvim_cmp = true;
        min_chars = 2;
      };

      picker = {
        name = "telescope.nvim";
        note_mappings = {
          new = "<C-x>";
          insert_link = "<C-l>";
        };
        tag_mappings = {
          tag_note = "<C-x>";
          insert_tag = "<C-l>";
        };
      };

      ui = {
        enable = true;
        update_debounce = 200;
        checkboxes = {
          " " = {
            char = "󰄱";
            hl_group = "ObsidianTodo";
            order = 1;
          };
          "x" = {
            char = "";
            hl_group = "ObsidianDone";
            order = 2;
          };
          ">" = {
            char = "";
            hl_group = "ObsidianRightArrow";
            order = 3;
          };
          "~" = {
            char = "󰰱";
            hl_group = "ObsidianTilde";
            order = 4;
          };
          "!" = {
            char = "";
            hl_group = "ObsidianImportant";
            order = 5;
          };
        };
        bullets = {
          char = "•";
          hl_group = "ObsidianBullet";
        };
        external_link_icon = {
          char = "";
          hl_group = "ObsidianExtLinkIcon";
        };
        hl_groups = {
          ObsidianTodo = {
            bold = true;
            fg = "#f78c6c";
          };
          ObsidianDone = {
            bold = true;
            fg = "#89ddff";
          };
          ObsidianRightArrow = {
            bold = true;
            fg = "#f78c6c";
          };
          ObsidianTilde = {
            bold = true;
            fg = "#ff5370";
          };
          ObsidianImportant = {
            bold = true;
            fg = "#d73128";
          };
          ObsidianBullet = {
            bold = true;
            fg = "#89ddff";
          };
          ObsidianRefText = {
            underline = true;
            fg = "#c792ea";
          };
          ObsidianExtLinkIcon = {
            fg = "#c792ea";
          };
          ObsidianTag = {
            italic = true;
            fg = "#89ddff";
          };
          ObsidianBlockID = {
            italic = true;
            fg = "#89ddff";
          };
          ObsidianHighlightText = {
            bg = "#75662e";
          };
        };
      };

      attachments = {
        img_folder = "assets/imgs";
        confirm_img_paste = true;
      };

      sort_by = "modified";
      sort_reversed = true;
      open_notes_in = "current";
    };
  };

  # Set up keymaps via extraConfigLua to use buffer-local mappings
  extraConfigLua = ''
    -- Obsidian keymaps (set up as buffer-local when in markdown files in vault)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local filename = vim.api.nvim_buf_get_name(bufnr)
        -- Only set up keymaps if we're in the obsidian vault
        if filename:match("^/snowscape/knowledge") then
          local opts = { buffer = bufnr, silent = true }

          -- gf passthrough for following links
          vim.keymap.set("n", "gf", function()
            return require("obsidian").util.gf_passthrough()
          end, vim.tbl_extend("force", opts, { expr = true, noremap = false }))

          -- Toggle checkbox
          vim.keymap.set("n", "<leader>ch", function()
            return require("obsidian").util.toggle_checkbox()
          end, opts)

          -- Smart action on enter
          vim.keymap.set("n", "<cr>", function()
            return require("obsidian").util.smart_action()
          end, vim.tbl_extend("force", opts, { expr = true }))
        end
      end,
    })
  '';

  keymaps = [
    {
      key = "<leader>on";
      action = "<cmd>ObsidianNew<CR>";
      options = {
        desc = "Obsidian: New note";
      };
    }
    {
      key = "<leader>oo";
      action = "<cmd>ObsidianQuickSwitch<CR>";
      options = {
        desc = "Obsidian: Quick switch";
      };
    }
    {
      key = "<leader>os";
      action = "<cmd>ObsidianSearch<CR>";
      options = {
        desc = "Obsidian: Search";
      };
    }
    {
      key = "<leader>ot";
      action = "<cmd>ObsidianToday<CR>";
      options = {
        desc = "Obsidian: Today's note";
      };
    }
    {
      key = "<leader>oy";
      action = "<cmd>ObsidianYesterday<CR>";
      options = {
        desc = "Obsidian: Yesterday's note";
      };
    }
    {
      key = "<leader>ob";
      action = "<cmd>ObsidianBacklinks<CR>";
      options = {
        desc = "Obsidian: Backlinks";
      };
    }
    {
      key = "<leader>ol";
      action = "<cmd>ObsidianLinks<CR>";
      options = {
        desc = "Obsidian: Links";
      };
    }
    {
      key = "<leader>og";
      action = "<cmd>ObsidianTags<CR>";
      options = {
        desc = "Obsidian: Tags";
      };
    }
    {
      key = "<leader>or";
      action = "<cmd>ObsidianRename<CR>";
      options = {
        desc = "Obsidian: Rename note";
      };
    }
    {
      key = "<leader>oi";
      action = "<cmd>ObsidianPasteImg<CR>";
      options = {
        desc = "Obsidian: Paste image";
      };
    }
    {
      mode = "v";
      key = "<leader>oe";
      action = "<cmd>ObsidianExtractNote<CR>";
      options = {
        desc = "Obsidian: Extract to note";
      };
    }
    {
      mode = "v";
      key = "<leader>ok";
      action = "<cmd>ObsidianLink<CR>";
      options = {
        desc = "Obsidian: Link selection";
      };
    }
    {
      mode = "v";
      key = "<leader>oln";
      action = "<cmd>ObsidianLinkNew<CR>";
      options = {
        desc = "Obsidian: Link to new note";
      };
    }
  ];
}
