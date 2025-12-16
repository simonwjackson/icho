{
  pkgs,
  project-picker-nvim,
  ...
}: {
  # fd is required for fast project discovery
  # tmux is required for session management
  # direnv is used to load project environment before starting nvim
  extraPackages = [pkgs.fd pkgs.tmux pkgs.direnv];

  # Add the plugin from flake input
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      pname = "project-picker.nvim";
      version = "0.1.0";
      src = project-picker-nvim;
    })
  ];

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
      -- Command to start neovim in new sessions
      -- Using direnv exec to load project environment before starting nvim
      nvim_cmd = "direnv exec . nvim",
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
