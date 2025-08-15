{pkgs, ...}: {
  extraPlugins = with pkgs; [
    vimPlugins.resession-nvim
  ];
  extraConfigLua = ''
    ${builtins.readFile ./resession.lua}
  '';
}
