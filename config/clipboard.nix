{pkgs, ...}: {
  extraPackages = with pkgs; [
    wl-clipboard
  ];

  # NOTE: Incase this plugin gets removed:
  # extraPlugins = [
  #   (pkgs.vimUtils.buildVimPlugin {
  #     name = "my-plugin";
  #     src = pkgs.fetchFromGitHub {
  #       owner = "ojroques";
  #       repo = "nvim-osc52";
  #       rev = "04cfaba1865ae5c53b6f887c3ca7304973824fb2";
  #       hash = "sha256:cVivuGzsG2bKfUBklyK7in0C8Xis0aO0pfyOuTol1mU=";
  #     };
  #   })
  # ];

  # plugins.nvim-osc52.enable = true;

  extraConfigLua = ''
    -- Configure native clipboard support
    vim.opt.clipboard = 'unnamedplus'
  '';
}
