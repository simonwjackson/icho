{
  plugins.overseer = {
    enable = true;
  };

  keymaps = [
    {
      key = "<leader>to";
      action = "<cmd>OverseerToggle<CR>";
      options = {
        desc = "Overseer: Task Overview";
      };
    }
    {
      key = "<leader>tl";
      action = "<cmd>OverseerRun<CR>";
      options = {
        desc = "Overseer: Task List (or new cmd)";
      };
    }
    {
      key = "<leader>tq";
      action = "<cmd>OverseerQuickAction<CR>";
      options = {
        desc = "Overseer: Previous Task Action";
      };
    }
    {
      key = "<leader>tr";
      action = "<cmd>OverseerQuickAction restart<CR>";
      options = {
        desc = "Overseer: Restart Last Action";
      };
    }
    {
      key = "<leader>tp";
      action = "<cmd>OverseerQuickAction open float<CR>";
      options = {
        desc = "Overseer: Preview Last Action";
      };
    }
    {
      key = "<leader>ta";
      action = "<cmd>OverseerTaskAction<CR>";
      options = {
        desc = "Overseer: Task Actions";
      };
    }
    {
      key = "<leader>tc";
      action = "<cmd>:OverseerRunCmd <CR>";
      options = {
        desc = "Overseer: Run arbitrary command";
      };
    }
  ];
}
