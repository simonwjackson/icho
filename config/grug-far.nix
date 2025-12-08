{ ... }: {
  plugins.grug-far = {
    enable = true;
    settings = {
      windowCreationCommand = "split";
      transient = true;
    };
  };

  keymaps = [
    {
      key = "<leader>S";
      action.__raw = ''
        function()
          require('grug-far').open()
        end
      '';
      options.desc = "Search and Replace";
    }
    {
      key = "<leader>S";
      mode = "v";
      action.__raw = ''
        function()
          require('grug-far').with_visual_selection()
        end
      '';
      options.desc = "Search and Replace (selection)";
    }
  ];
}
