{pkgs, ...}: {
  plugins.overseer = {
    enable = true;
    package =
      pkgs.vimUtils.buildVimPlugin
      {
        name = "overseer-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "simonwjackson";
          repo = "overseer.nvim";
          rev = "custom";
          sha256 = "sha256-6cFaN603Cq+1KBpasE1wSBYtkSItXnAgcHKZQDsuiDA=";
        };
        doCheck = false;
      };
  };

  keymaps = [
    {
      key = "<leader>tt";
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
      key = "<leader>ta";
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
      key = "<leader>tA";
      action = "<cmd>OverseerTaskAction<CR>";
      options = {
        desc = "Overseer: Task Actions";
      };
    }
  ];
}
