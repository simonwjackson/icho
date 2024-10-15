{pkgs}: {
  packages = [
    pkgs.ripgrep
    # pkgs.nushell
  ];

  environment = {
  };

  replace = {
    animation = pkgs.awesomeNeovimPlugins.animation-nvim;
    betterEscape = pkgs.awesomeNeovimPlugins.better-escape-nvim;
    boole = pkgs.awesomeNeovimPlugins.boole-nvim;
    buffDelete = pkgs.awesomeNeovimPlugins.bufdelete-nvim;
    chainsaw = pkgs.awesomeNeovimPlugins.nvim-chainsaw;
    cutlass = pkgs.awesomeNeovimPlugins.cutlass-nvim;
    detour = pkgs.vimPlugins.detour;
    diffview = pkgs.awesomeNeovimPlugins.diffview-nvim;
    dressing = pkgs.awesomeNeovimPlugins.dressing-nvim;
    gitBlame = pkgs.awesomeNeovimPlugins.git-blame-nvim;
    gitDev = pkgs.awesomeNeovimPlugins.git-dev-nvim;
    # hmtsNvim = pkgs.vimPlugins.hmts-nvim;
    isVim = pkgs.vimPlugins.is-vim;
    just = pkgs.vimPlugins.tree-sitter-just;
    lspSignature = pkgs.awesomeNeovimPlugins.lsp-signature-nvim;
    mTaskwarriorD = pkgs.vimPlugins.m_taskwarriror_d;
    # mdxNvim = pkgs.vimPlugins.mdx-nvim;
    middleclass = pkgs.vimPlugins.middleclass;
    mkdir = pkgs.awesomeNeovimPlugins.mkdir-nvim;
    neodim = pkgs.awesomeNeovimPlugins.neodim;
    nui = pkgs.awesomeNeovimPlugins.nui-nvim;
    numb = pkgs.awesomeNeovimPlugins.numb-nvim;
    # nvimNu = pkgs.vimPlugins.nvim-nu;
    nvimScrollbar = pkgs.awesomeNeovimPlugins.nvim-scrollbar;
    nvimSpectre = pkgs.awesomeNeovimPlugins.nvim-spectre;
    nvimTreesitter = pkgs.vimPlugins.nvim-treesitter;
    obsidian = pkgs.awesomeNeovimPlugins.obsidian-nvim;
    oneDark = pkgs.awesomeNeovimPlugins.onedark-nvim;
    # otter = pkgs.awesomeNeovimPlugins.otter-nvim;
    overseer = pkgs.awesomeNeovimPlugins.overseer-nvim;
    plenary = pkgs.vimPlugins.plenary-nvim;
    pqf = pkgs.awesomeNeovimPlugins.nvim-pqf;
    rosePine = pkgs.awesomeNeovimPlugins.rose-pine-neovim;
    sentiment = pkgs.awesomeNeovimPlugins.sentiment-nvim;
    smartSplits = pkgs.awesomeNeovimPlugins.smart-splits-nvim;
    surround = pkgs.awesomeNeovimPlugins.nvim-surround;
    telescope = pkgs.awesomeNeovimPlugins.telescope-nvim;
    telescopeTabs = pkgs.awesomeNeovimPlugins.telescope-tabs;
    telescopeUndo = pkgs.awesomeNeovimPlugins.telescope-undo-nvim;
    vimHighlightedyank = pkgs.vimPlugins.vim-highlightedyank;
    vimVisualStarSearch = pkgs.vimPlugins.vim-visual-star-search;
    windows = pkgs.awesomeNeovimPlugins.windows-nvim;
  };
}
