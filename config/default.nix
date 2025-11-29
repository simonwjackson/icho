{ ... }:
{
  imports = [
    ./agents
    ./clipboard.nix
    ./plugins/claude-instances
    ./color.nix
    ./completion.nix
    ./database.nix
    ./editing.nix
    ./fidget.nix
    ./filetree.nix
    ./files.nix
    ./formatting.nix
    ./git.nix
    ./gutter.nix
    ./http.nix
    ./lsp.nix
    ./markdown.nix
    ./movements.nix
    ./navigation.nix
    ./obsidian.nix
    ./sessions
    ./snippets.nix
    ./splits.nix
    ./splash.nix
    ./syntax.nix
    ./tabs
    ./tasks.nix
    ./telescope.nix
    ./terminal.nix
    ./treesitter.nix
    ./ui.nix
    ./utilities.nix
  ];

  extraConfigLua = ''
    local opt = vim.opt

    -- Liquid template filetype detection
    vim.filetype.add({
      extension = {
        liquid = 'liquid',
      },
      pattern = {
        ['.*%.ts%.liquid'] = 'liquid',
        ['.*%.tsx%.liquid'] = 'liquid',
        ['.*%.js%.liquid'] = 'liquid',
        ['.*%.jsx%.liquid'] = 'liquid',
        ['.*%.nix%.liquid'] = 'liquid',
        ['.*%.json%.liquid'] = 'liquid',
        ['.*%.html%.liquid'] = 'liquid',
        ['.*%.css%.liquid'] = 'liquid',
        ['.*%.md%.liquid'] = 'liquid',
      },
    })

    opt.shortmess:append('filnxtToOCcIF')

    -- Persist undo history between sessions
    opt.undofile = true;

    --- CUSTOM ---
    opt.splitkeep = "screen" -- keeps the same screen screen lines in all split windows
    opt.signcolumn = "yes"

    opt.splitbelow = true
    opt.splitright = true
    opt.termguicolors = true
    opt.timeoutlen = 400
    opt.undofile = true
    opt.scrollback = 100000

    -- Indenting
    opt.expandtab = true
    opt.shiftwidth = 2
    opt.smartindent = true
    opt.tabstop = 2
    opt.softtabstop = 2

    opt.fillchars = {
      eob = " ",
      diff = '/',
      stl = ' ',  -- statusline fill char (space to hide statuslines)
      stlnc = ' ', -- non-current window statusline fill char
    }
    opt.ignorecase = true
    opt.smartcase = true
    opt.mouse = "a"

    -- Numbers
    opt.number = false
    opt.numberwidth = 2
    opt.ruler = false

    -- Command line
    opt.cmdheight = 0

    -- Disable status line
    opt.laststatus = 3
  '';
}
