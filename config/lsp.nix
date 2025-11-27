{pkgs, ...}: {
  extraPackages = [
    pkgs.nodejs_latest
  ];
  plugins.lspkind.enable = true;
  plugins.lsp = {
    keymaps = {
      lspBuf = {
        gd = {
          action = "definition";
          desc = "Go to definition";
        };
        gD = {
          action = "declaration";
          desc = "Go to declaration";
        };
        gr = {
          action = "references";
          desc = "Find references";
        };
        gi = {
          action = "implementation";
          desc = "Go to implementation";
        };
        K = {
          action = "hover";
          desc = "Hover documentation";
        };
        "<leader>rn" = {
          action = "rename";
          desc = "Rename symbol";
        };
        "<leader>ca" = {
          action = "code_action";
          desc = "Code action";
        };
      };
    };
    enable = true;
    servers = {
      astro = {enable = true;};
      bashls = {enable = true;};
      cssls = {enable = true;};
      elmls = {
        enable = true;
        settings = {
          elmAnalyseTrigger = "change";
          elmFormatPath = "elm-format";
          elmPath = "elm";
        };
      };
      emmet_ls = {enable = true;};
      eslint = {enable = true;};
      html = {enable = true;};
      htmx = {enable = true;};
      jqls = {enable = true;};
      jsonls = {enable = true;};
      lua_ls = {
        enable = true;
        settings = {
          diagnostics.globals = ["vim"];
          workspace = {
            library = [
              {__raw = ''vim.fn.expand "$VIMRUNTIME"'';}
              {__raw = ''vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"'';}
              "\${3rd}/luv/library"
            ];
          };
        };
      };
      nil_ls = {enable = true;};
      pyright = {enable = true;};
      ruff = {enable = true;};
      tailwindcss = {
        enable = true;
        settings = {
          tailwindCSS = {
            validate = true;
            lint = {cssConflict = "warning";};
          };
        };
      };
      ts_ls = {enable = true;};
      yamlls = {enable = true;};
    };
  };
}
