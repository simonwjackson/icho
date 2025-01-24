{
  keymaps = [
    {
      key = "<leader>ff";
      action = "<cmd> Telescope find_files <CR>";
      options = {
        desc = "Find files";
      };
    }

    {
      key = "<leader>fg";
      action = "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>";
      options = {
        desc = "Find all files";
      };
    }

    {
      key = "<leader>fw";
      action = "<cmd> Telescope live_grep <CR>";
      options = {
        desc = "Live grep";
      };
    }

    {
      key = "<leader>fo";
      action = "<cmd> Telescope oldfiles <CR>";
      options = {
        desc = "Find oldfiles";
      };
    }

    {
      key = "<leader>gc";
      action = "<cmd> Telescope git_commits <CR>";
      options = {
        desc = "Git commits";
      };
    }

    {
      key = "<leader>gs";
      action = "<cmd> Telescope git_status <CR>";
      options = {
        desc = "Git status";
      };
    }
  ];

  plugins.telescope = {
    enable = true;
    settings = {
    };
  };
}
