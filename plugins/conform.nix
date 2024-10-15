{pkgs}: {
  packages = [
    pkgs.alejandra
    pkgs.black
    pkgs.elmPackages.elm-format
    pkgs.eslint_d
    pkgs.gawk
    pkgs.isort
    pkgs.jq
    pkgs.just
    pkgs.nodejs
    pkgs.prettierd
    pkgs.shfmt
    pkgs.stylua
    pkgs.yq-go
  ];

  environment = {
  };

  environmentFiles = [
  ];

  extraPackages = [
    pkgs.cowsay
  ];

  replace = {
    conform = pkgs.awesomeNeovimPlugins.conform-nvim;
  };
}
