{ pkgs, ... }: {
  plugins.lsp = {
    enable = true;

    keymaps = {
      # Standard LSP keymaps
      lspBuf = {
        K = "hover";
        gD = "declaration";
        "<leader>ca" = "code_action";
        "<leader>rn" = "rename";
        "<leader>lf" = "format";
      };
      diagnostic = {
        "[d" = "goto_prev";
        "]d" = "goto_next";
        "<leader>ld" = "open_float";
      };
    };

    servers = {
      # Nix
      nil_ls = {
        enable = true;
        settings = {
          formatting.command = [ "alejandra" ];
          nix.flake.autoArchive = true;
        };
      };

      # Lua (neovim config)
      lua_ls = {
        enable = true;
        settings = {
          Lua = {
            runtime.version = "LuaJIT";
            workspace.checkThirdParty = false;
            telemetry.enable = false;
            diagnostics = {
              globals = [ "vim" ];
            };
          };
        };
      };

      # TypeScript/JavaScript
      ts_ls = {
        enable = true;
      };

      # Python
      pyright = {
        enable = true;
      };

      # Bash
      bashls = {
        enable = true;
      };

      # HTML
      html = {
        enable = true;
      };

      # Tailwind CSS
      tailwindcss = {
        enable = true;
      };

      # Biome (linting + formatting for JS/TS/JSON)
      # Only loads when biome.json or biome.jsonc exists in project
      biome = {
        enable = true;
        rootMarkers = [ "biome.json" "biome.jsonc" ];
      };

      # JSON with SchemaStore
      jsonls = {
        enable = true;
        extraOptions = {
          settings = {
            json = {
              validate = { enable = true; };
            };
          };
        };
      };

      # YAML with SchemaStore
      yamlls = {
        enable = true;
        extraOptions = {
          settings = {
            yaml = {
              validate = true;
              schemaStore = {
                enable = true;
                url = "https://www.schemastore.org/api/json/catalog.json";
              };
            };
          };
        };
      };
    };
  };

  # SchemaStore for JSON/YAML schemas
  plugins.schemastore = {
    enable = true;
    json.enable = true;
    yaml.enable = true;
  };

  # Use snacks.picker for LSP navigation (already configured in snacks.nix)
  # gd, gr, gi are mapped there
}
