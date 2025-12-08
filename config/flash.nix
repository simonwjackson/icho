{
  plugins.flash = {
    enable = true;
    settings = {
      modes = {
        char = {
          jump_labels = true;
        };
      };
    };
  };

  keymaps = [
    { key = "s"; action.__raw = "function() require('flash').jump() end"; options.desc = "Flash"; mode = ["n" "x" "o"]; }
    { key = "S"; action.__raw = "function() require('flash').treesitter() end"; options.desc = "Flash Treesitter"; mode = ["n" "x" "o"]; }
    { key = "r"; action.__raw = "function() require('flash').remote() end"; options.desc = "Remote Flash"; mode = ["o"]; }
    { key = "R"; action.__raw = "function() require('flash').treesitter_search() end"; options.desc = "Treesitter Search"; mode = ["o" "x"]; }
    { key = "<c-s>"; action.__raw = "function() require('flash').toggle() end"; options.desc = "Toggle Flash Search"; mode = ["c"]; }
  ];
}
