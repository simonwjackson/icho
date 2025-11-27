{...}: {
  keymaps = [
    {
      mode = "n";
      key = "<leader>oo";
      action = "<cmd>Obsidian quick_switch<cr>";
      options.desc = "Quick switch notes";
    }
    {
      mode = "n";
      key = "<leader>on";
      action = "<cmd>Obsidian new<cr>";
      options.desc = "New note";
    }
    {
      mode = "n";
      key = "<leader>os";
      action = "<cmd>Obsidian search<cr>";
      options.desc = "Search notes";
    }
    {
      mode = "n";
      key = "<leader>ob";
      action = "<cmd>Obsidian backlinks<cr>";
      options.desc = "Backlinks";
    }
    {
      mode = "n";
      key = "<leader>ol";
      action = "<cmd>Obsidian links<cr>";
      options.desc = "Outgoing links";
    }
    {
      mode = "n";
      key = "<leader>ot";
      action = "<cmd>Obsidian tags<cr>";
      options.desc = "Tags";
    }
    {
      mode = "n";
      key = "<leader>od";
      action = "<cmd>Obsidian today<cr>";
      options.desc = "Today's daily note";
    }
    {
      mode = "n";
      key = "<leader>of";
      action = "<cmd>Obsidian follow_link<cr>";
      options.desc = "Follow link";
    }
    {
      mode = "n";
      key = "<leader>or";
      action = "<cmd>Obsidian rename<cr>";
      options.desc = "Rename note";
    }
  ];

  plugins.obsidian = {
    enable = true;
    autoLoad = true;
    settings = {
      legacy_commands = false;
      workspaces = [
        {
          name = "personal";
          path = "/snowscape/knowledge";
        }
      ];
      ui.enable = false;
      preferred_link_style = "markdown";
      new_notes_location = "notes_subdir";
      notes_subdir = "00-inbox";
      note_id_func.__raw = ''
        function(title)
          local suffix = ""
          if title ~= nil then
            suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
          else
            for _ = 1, 4 do
              suffix = suffix .. string.char(math.random(65, 90))
            end
          end
          return tostring(os.time()) .. "-" .. suffix
        end
      '';
    };
  };
}
