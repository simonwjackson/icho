{ pkgs, ... }:
{
  # fd is required for fast project discovery
  # tmux is required for session management
  extraPackages = [ pkgs.fd pkgs.tmux ];

  # Add lua files to the runtime path
  extraFiles = {
    "lua/project-picker/init.lua".source = ./project-picker/init.lua;
    "lua/project-picker/finder.lua".source = ./project-picker/finder.lua;
    "lua/project-picker/tmux.lua".source = ./project-picker/tmux.lua;
  };

  extraConfigLua = ''
    -- Setup project picker with configuration
    require("project-picker").setup({
      -- Root directories to search for projects
      directories = {
        "~/projects",
        "~/code",
        "/snowscape/code",
      },
      -- Maximum depth to search (for fd)
      max_depth = 5,
      -- Start neovim in new sessions
      start_nvim = true,
      -- Cache TTL in seconds (0 to disable)
      cache_ttl = 300,
    })
  '';

  keymaps = [
    {
      key = "<leader>p";
      action.__raw = "function() require('project-picker').pick() end";
      options.desc = "Open project picker";
    }
  ];
}
