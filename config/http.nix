{...}: {
  plugins = {
    # TODO: Re-enable once kulala_http treesitter parser is packaged
    # kulala tries to auto-install its parser which fails in nix sandbox
    kulala = {
      enable = false;
      settings = {
        additional_curl_options = {};
        debug = false;
        default_env = "dev";
        default_view = "body";
        environment_scope = "b";
        icons = {
          inlay = {
            done = "";
            error = "";
            loading = "";
          };
          lualine = "";
        };
      };
    };
    rest.enable = true;
  };
}
