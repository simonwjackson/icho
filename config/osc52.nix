{pkgs, ...}: {
  extraPackages = with pkgs; [
    wl-clipboard
  ];
  clipboard = {
    # Use system clipboard for all operations
    register = "unnamedplus";
  };

  extraConfigLua = ''
    vim.g.max_osc52_length = 0

    vim.g.clipboard = {
      name = 'OSC 52',
      copy = {
        ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
        ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
      },
      paste = {
        ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
        ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
      },
    }
  '';
}
