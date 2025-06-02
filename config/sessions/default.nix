{pkgs, ...}: {
  extraPlugins = with pkgs; [
    (vimUtils.buildVimPlugin {
      name = "resession-nvim";
      src = pkgs.fetchFromGitHub {
        owner = "stevearc";
        repo = "resession.nvim";
        rev = "master";
        hash = "sha256:Xck5ACTLKdUBHOZgVqSQ+jQ2AVLE0QOsE+fcH8UJG8o=";
      };
    })
  ];
  extraConfigLua = ''
    ${builtins.readFile ./resession.lua}
  '';
}
