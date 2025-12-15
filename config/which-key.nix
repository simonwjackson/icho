{
  plugins.which-key = {
    enable = true;
    settings = {
      win = {
        border = "rounded";
      };
      spec = [
        { __unkeyed-1 = "<leader>a"; group = "AI/Opencode"; }
        { __unkeyed-1 = "<leader>g"; group = "Git"; }
        {
          __unkeyed-1 = "<leader>w";
          group = "windows";
          proxy = "<C-w>";
        }
      ];
    };
  };
}
