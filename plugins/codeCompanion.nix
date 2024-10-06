{pkgs}: {
  packages = [
  ];

  environment = {
  };
  replace = {
    codeCompanion = pkgs.awesomeNeovimPlugins.codecompanion-nvim;
    plenary = pkgs.vimPlugins.plenary-nvim;
    dressing = pkgs.awesomeNeovimPlugins.dressing-nvim;
    telescope = pkgs.awesomeNeovimPlugins.telescope-nvim;
    edgyNvim = pkgs.vimPlugins.edgy-nvim;
    treesitterYaml = (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [p.yaml])).dependencies;
  };
}
