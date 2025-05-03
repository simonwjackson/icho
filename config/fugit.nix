{
  pkgs,
  lib,
  ...
}: {
  plugins = {
    fugit2 = {
      enable = true;
      settings = {
        width = 100;
        max_width = "80%";
        height = "60%";
        show_patch = false;
        external_diffview = false;
        blame_priority = 1;
        blame_info_width = 60;
        blame_info_height = 10;
      };
    };
  };

  keymaps = [
    {
      key = "<leader>gg";
      action = "<cmd>Fugit2<CR>";
      options = {
        desc = "Git: Status";
      };
    }
    {
      key = "<leader>gd";
      action = "<cmd>Fugit2Diff<CR>";
      options = {
        desc = "Git: Diff";
      };
    }
  ];
}

