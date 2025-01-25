{...}: {
  plugins.lsp-lines.enable = true;
  plugins.lspkind.enable = true;
  plugins.lsp = {
    enable = true;
    servers = {
      nil_ls = {
        enable = true;
      };
      bashls = {
        enable = true;
      };
      cssls = {
        enable = true;
      };
      elmls = {
        enable = true;
        settings = {
          elmAnalyseTrigger = "change";
          elmFormatPath = "elm-format";
          elmPath = "elm";
        };
      };
      emmet_ls = {
        enable = true;
      };
      html = {
        enable = true;
      };
      jsonls = {
        enable = true;
      };
      lua_ls = {
        enable = true;
      };
      ts_ls = {
        enable = true;
      };
      yamlls = {
        enable = true;
      };
      jqls = {
        enable = true;
      };
      htmx = {
        enable = true;
      };
      nixd = {
        enable = true;
      };
      eslint = {
        enable = true;
      };

      tailwindcss = {
        enable = true;
        settings = {
          tailwindCSS = {
            validate = true;
            lint = {
              cssConflict = "warning";
            };
          };
        };
      };
    };
  };
}
