{pkgs, ...}: {
  extraPackages = [
    pkgs.neovim-remote
  ];

  keymaps = [
    {
      key = "<leader>fe";
      action = ''
        <cmd>TermExec cmd="${pkgs.lib.getExe pkgs.lf} %; exit" direction=float<cr>
      '';
      options = {
        desc = "Open lf file manager";
        silent = true;
        noremap = true;
      };
    }
  ];

  plugins.toggleterm = {
    enable = true;
    autoLoad = true;
    settings = {
      direction = "float";
      float_opts = {
        border = "curved";
        height = 30;
        width = 130;
      };
      open_mapping = "[[<a-.>]]";
      highlights = {
        FloatBorder = {
          link = "FloatBorder";
        };
      };
    };
  };
}
