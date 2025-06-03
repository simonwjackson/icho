{pkgs, ...}: {
  extraPackages = with pkgs; [
    wl-clipboard
  ];

  extraConfigLua = ''
    -- Configure clipboard for nested tmux sessions
    -- Use OSC 52 for better compatibility with nested tmux
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
    
    -- Ensure clipboard integration is enabled
    vim.opt.clipboard = 'unnamedplus'
  '';
}
