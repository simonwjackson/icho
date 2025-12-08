{ pkgs, ... }: {
  # Fallback clipboard provider for Wayland
  extraPackages = with pkgs; [
    wl-clipboard
  ];

  # Use system clipboard
  opts.clipboard = "unnamedplus";

  # OSC 52 for clipboard over SSH/tmux (built into neovim 0.10+)
  extraConfigLua = ''
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
