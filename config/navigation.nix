{...}: {
  plugins = {
    marks.enable = true;
    navbuddy = {
      enable = true;
      settings = {
        lsp = {
          auto_attach = true;
        };
      };
    };
    glance.enable = true;
    improved-search.enable = true;
  };
}
