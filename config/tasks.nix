{ pkgs, vim-overseer, ... }: {
  plugins.overseer = {
    enable = true;
    package = pkgs.vimUtils.buildVimPlugin {
      name = "overseer-nvim";
      src = vim-overseer;
      doCheck = false;
    };
  };

  keymaps = [
    {
      key = "<leader>tt";
      action = "<cmd>OverseerToggle<CR>";
      options.desc = "Task Overview";
    }
    {
      key = "<leader>tl";
      action = "<cmd>OverseerRun<CR>";
      options.desc = "Task List";
    }
    {
      key = "<leader>ta";
      action = "<cmd>OverseerQuickAction<CR>";
      options.desc = "Previous Task Action";
    }
    {
      key = "<leader>tr";
      action = "<cmd>OverseerQuickAction restart<CR>";
      options.desc = "Restart Last Task";
    }
    {
      key = "<leader>tA";
      action = "<cmd>OverseerTaskAction<CR>";
      options.desc = "Task Actions";
    }
  ];
}
