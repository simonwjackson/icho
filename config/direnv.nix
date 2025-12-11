{ pkgs, direnv-nvim, ... }:
{
  extraPackages = [ pkgs.direnv ];

  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "direnv-nvim";
      src = direnv-nvim;
      doCheck = false;
    })
  ];

  extraConfigLua = ''
    require("direnv").setup({
      autoload = true,
      async = true,
    })
  '';
}
