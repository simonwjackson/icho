{
  pkgs,
  lib,
  ...
}: {
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "detour";
      src = pkgs.fetchFromGitHub {
        owner = "carbon-steel";
        repo = "detour.nvim";
        rev = "5647e8ce16e53e42734244c56a8d3ecb3f214f0d";
        hash = "sha256-SbEEFL2Zfmb+ERDaAVuXeLWpSdDQdEj5WHwSAjdvuYI=";
      };
    })
    pkgs.vimPlugins.middleclass
    pkgs.vimPlugins.windows-nvim
  ];

  extraConfigLua = ''
    vim.o.winwidth = 20
    vim.o.winminwidth = 20
    vim.o.equalalways = false

    require("windows").setup({
      animation = {
        enable = true,
        duration = 60,
        fps = 60,
        easing = "in_out_sine",
      },
      autowidth = {
        enable = true,
        winwidth = 0.6, -- This sets your "master" window to 60% of screen
        filetype = { -- Opt-out for specific filetypes
          help = false,
          qf = false,
          startuptime = false,
        },
      }
    })

    require("detour").setup({
        width = 0.75,    -- Width as a percentage of screen width (0.0 - 1.0)
        height = 0.75,   -- Height as a percentage of screen height (0.0 - 1.0)
    })
  '';

  plugins.smart-splits = {
    enable = true;
  };

  plugins.mini = {
    enable = true;
    modules.diff.options.view.style = "sign";
  };

  plugins.blink-cmp = {
    enable = true;
    settings = {
      enabled = lib.nixvim.mkRaw ''
        function()
          return (
            vim.bo.filetype == 'codecompanion'
            and vim.bo.buftype ~= 'prompt'
            and vim.b.completion ~= false
          )
            or vim.fn.getcmdtype() ~= ""
          end
      '';
      keymap = {
        preset = "super-tab";
      };
      sources = {
        per_filetype = {
          codecompanion = ["codecompanion"];
        };
      };
    };
  };

  keymaps = [
    {
      key = "<leader>al";
      action = "<cmd>CodeCompanionActions<cr>";
      options = {
        desc = "AI Actions: Show";
      };
    }
    {
      key = "<leader>aa";
      action = "<cmd>CodeCompanionChat Toggle<cr>";
      options = {
        desc = "AI Chat: Toggle";
      };
    }
    {
      key = "<leader>at";
      action = ":CodeCompanion /terminal ";
      options = {
        desc = "AI Chat: Toggle";
      };
    }
    {
      key = "<leader><leader>al";
      action = "<cmd>CodeCompanion<cr>";
      options = {
        desc = "AI Chat: Prompt";
      };
    }
    {
      key = "<leader>ab";
      action = ":CodeCompanionChat /buffer";
      options = {
        desc = "AI Chat: Prompt";
      };
    }
    {
      key = "<leader><leader>ab";
      action = ":CodeCompanion /buffer ";
      options = {
        desc = "AI Chat: Prompt";
      };
    }
    {
      key = "<leader>an";
      action = "<cmd>CodeCompanionChat<cr>";
      options = {
        desc = "AI Chat: New";
      };
    }
    {
      key = "ga";
      action = "<cmd>CodeCompanionChat Add<cr>";
      options = {
        desc = "AI Chat: Add";
      };
    }
  ];

  plugins.codecompanion = {
    enable = true;
    settings = {
      prompt_library = {
        "Auto-generate git commit message" = {
          strategy = "inline";
          description = "Generate git commit message for current staged changes";
          opts = {
            mapping = "<leader>acm";
            placement = "before|false";
          };
          prompts = [
            {
              role = "user";
              contains_code = true;
              content = {
                __raw = ''
                  function()
                    return [[You are an expert at following the Conventional Commit specification based on the following diff:
                    ]] .. vim.fn.system("git diff --cached") .. [[
                    Generate a commit message for me. Follow the below structure:

                    ```
                    <type>[optional scope]: <description>
                    <BLANK LINE>
                    <pithy bullet points. 3 max>
                    ```

                    Return the code only and no markdown codeblocks.
                    ]]
                  end
                '';
              };
            }
          ];
        };
      };
      display = {
        diff = {
          enabled = true;
          provider = "mini_diff";
        };
        chat = {
          diff = {
            enabled = true;
            provider = "mini_diff";
          };
          window = {
            layout = "float";
            height = 0.8;
            width = 0.6;
          };
        };
        action_palette = {
          width = 100;
          height = 10;
          provider = "default";
        };
      };
      strategies = {
        chat = {
          adapter = "deepseek";
          slash_commands = {
            help = {
              opts = {
                provider = "telescope";
              };
            };
            buffer = {
              opts = {
                provider = "telescope";
              };
            };
            file = {
              opts = {
                provider = "telescope";
              };
            };
          };
          keymaps = {
            send = {
              modes = {
                n = ["<C-s>" "<C-Enter>" "<Enter>"];
                i = ["<C-s>" "<C-Enter>"];
              };
            };
            close = {
              modes = {
                n = ["<C-c>"];
                i = ["<C-c>"];
              };
            };
          };
        };
        inline = {
          adapter = "deepseek";
        };
        agent = {
          adapter = "deepseek";
        };
      };
      adapters = {
        deepseek = {
          __raw = ''
            function()
              return require("codecompanion.adapters").extend("openai", {
                name = "deepseek",
                  schema = {
                    model = {
                      default = "deepseek-chat",
                          choices = {
                            "deepseek-chat",
                            "deepseek-reasoner",
                          },
                    },
                 },
                 url = "https://api.deepseek.com/v1/chat/completions",
                 env = {
                   api_key = "DEEPSEEK_API_KEY",
                 },
               })
            end
          '';
        };
        anthropic = {
          __raw = ''
            function()
              return require("codecompanion.adapters").extend("anthropic", {})
            end
          '';
        };
      };
    };
  };
}
