{...}: {
  plugins = {
    # QOL
    vim-suda = {
      enable = true;
    };

    # Editing
    vim-matchup = {
      enable = true;
      treesitter.enable = true;
    };
    repeat.enable = true;
    nvim-surround.enable = true;
    comment.enable = true;
  };

  keymaps = [
    {
      key = "<c-s>";
      action = "<cmd>update<CR>";
      options = {
        desc = "Save File";
      };
    }
  ];
}
