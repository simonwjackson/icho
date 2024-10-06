{pkgs}: {
  packages = [
    pkgs.ripgrep
  ];
  replace = {
    telescope = pkgs.awesomeNeovimPlugins.telescope-nvim;
    advancedGitSearch = pkgs.awesomeNeovimPlugins.advanced-git-search-nvim;
    vimFugitive = pkgs.vimPlugins.vim-fugitive;
    vimRhubarb = pkgs.vimPlugins.vim-rhubarb;
    diffview = pkgs.awesomeNeovimPlugins.diffview-nvim;
    plenary = pkgs.vimPlugins.plenary-nvim;
    ripgrep = pkgs.vimPlugins.ripgrep;
    fd = pkgs.vimPlugins.fd;
    nvimWebDevicons = pkgs.vimPlugins.nvim-web-devicons;
  };
}
