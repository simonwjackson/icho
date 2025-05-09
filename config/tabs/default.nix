{pkgs, ...}: {
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "tabby-nvim";
      src = pkgs.fetchFromGitHub {
        owner = "nanozuki";
        repo = "tabby.nvim";
        rev = "main";
        sha256 = "sha256-I6ShLFhRj3pdSFqEOViXhWzL9UnrXcs7IFtgRsnIo30=";
      };
    })
    pkgs.vimPlugins.nvim-web-devicons # Optional dependency for file icons
  ];

  extraConfigLua = ''
    ${builtins.readFile ./tabby.lua}
  '';

  keymaps = [
    {
      key = "<leader><leader>tq";
      action = "<cmd>tabclose<CR>";
      options = {
        desc = "Tab: Close";
      };
    }
    {
      key = "<leader><leader>tt";
      action = "<cmd>tabnew<CR>";
      options = {
        desc = "Tab: New";
      };
    }
    {
      key = "<leader><leader>tT";
      action = ":tabnew<CR>:terminal<CR>:startinsert<CR>";
      options = {
        desc = "Open new tab with terminal in insert mode (nobuflisted)";
      };
    }
    {
      key = "<leader><leader>tr";
      action = "<cmd>Tabby rename_tab";
      options = {
        desc = "Tab: Rename";
      };
    }
    {
      key = "<leader><leader>tw";
      action = "<cmd>Tabby pick_window<CR>";
      options = {
        desc = "Tab: Pick window";
      };
    }
    {
      key = "<leader><leader>ts";
      action = "<cmd>Tabby jump_to_tab<CR>";
      options = {
        desc = "Tab: Jump to tab";
      };
    }
    {
      key = "<a-c-l>";
      action = "<cmd>tabnext<CR>";
      options = {
        desc = "Tab: Next";
      };
    }
    {
      key = "<a-c-h>";
      action = "<cmd>tabprevious<CR>";
      options = {
        desc = "Tab: Previous";
      };
    }
    {
      key = "<A-C-j>";
      action = "<cmd>bnext<CR>";
      options = {
        desc = "Next buffer";
      };
    }
    {
      key = "<A-C-k>";
      action = "<cmd>bprevious<CR>";
      options = {
        desc = "Previous buffer";
      };
    }
  ];
}
