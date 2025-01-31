{
  pkgs,
  lib,
  ...
}: let
  # HACK: There is an issue with the LSP server and embedded lua code
  unDerscore = str: builtins.replaceStrings ["_("] ["("] str;
in {
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

  extraConfigLua =
    # lua
    ''
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

  plugins.blink-cmp = {
    enable = true;
    settings = {
      enabled = let
        lua =
          unDerscore
          # lua
          ''
            function _()
              return (
                vim.bo.filetype == 'codecompanion'
                and vim.bo.buftype ~= 'prompt'
                and vim.b.completion ~= false
              )
                or vim.fn.getcmdtype() ~= ""
            end
          '';
      in
        lib.nixvim.mkRaw lua;
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
      key = "<leader>ac";
      action = ":CodeCompanionCmd ";
      options = {
        desc = "AI Actions: nvim cmd";
      };
    }
    {
      key = "<leader>al";
      action = "<cmd>CodeCompanionActions<cr>";
      options = {
        desc = "AI Actions: Show";
      };
    }
    {
      key = "<c-space>";
      action = "<cmd>CodeCompanionChat Toggle<cr>";
      options = {
        desc = "AI Chat: Toggle";
      };
    }
    {
      key = "<c-s-space>";
      action = "<cmd>CodeCompanionChat<cr>";
      options = {
        desc = "AI Chat: Toggle";
      };
    }
    {
      key = "<leader>at";
      action = "<cmd>CodeCompanionChat Toggle<cr>";
      options = {
        desc = "AI Chat: Toggle";
      };
    }
    {
      key = "<leader>ap";
      action = "<cmd>CodeCompanion<cr>";
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
        "Generate a Commit Message" = {
          strategy = "inline";
          description = "Generate git commit message for current staged changes";
          opts = {
            index = 10;
            mapping = "<leader>acm";
            placement = "before|false";
            short_name = "commit";
            is_default = true;
            is_slash_cmd = true;
            auto_submit = false;
          };
          prompts = [
            {
              role = "user";
              contains_code = true;
              content = {
                __raw =
                  unDerscore
                  # lua
                  ''
                    function _()
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

        # "Code Expert" = {
        #   strategy = "chat";
        #   description = "Get some special advice from an LLM";
        #   opts = {
        #     mapping = "<Leader>ae";
        #     modes = ["v"];
        #     short_name = "expert";
        #     auto_submit = true;
        #     stop_context_insertion = true;
        #     user_prompt = true;
        #   };
        #   prompts = [
        #     {
        #       role = "system";
        #       content = {
        #         __raw =
        #           unDerscore
        #           # lua
        #           ''
        #             function _(context)
        #               return "I want you to act as a senior "
        #                 .. context.filetype
        #                 .. " developer. I will ask you specific questions and I want you to return concise explanations and codeblock examples.";
        #              end
        #           '';
        #       };
        #     }
        #     {
        #       role = "user";
        #       content = {
        #         __raw =
        #           unDerscore
        #           # lua
        #           ''
        #             function _(context)
        #               local text = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line);

        #               return "I have the following code:\n\n```" .. context.filetype .. "\n" .. text .. "\n```\n\n";
        #             end
        #           '';
        #       };
        #       opts = {
        #         contains_code = true;
        #       };
        #     }
        #   ];
        # };

        # "Explain" = {
        #   strategy = "chat";
        #   description = "Explain how code in a buffer works";
        #   opts = {
        #     index = 5;
        #     is_default = true;
        #     is_slash_cmd = false;
        #     modes = ["v"];
        #     short_name = "explain";
        #     auto_submit = true;
        #     user_prompt = false;
        #     stop_context_insertion = true;
        #   };
        #   prompts = [
        #     {
        #       role = "system";
        #       content = {
        #         __raw =
        #           unDerscore
        #           # lua
        #           ''
        #             function _()
        #               return [[When asked to explain code, follow these steps:

        #             1. Identify the programming language.
        #             2. Describe the purpose of the code and reference core concepts from the programming language.
        #             3. Explain each function or significant block of code, including parameters and return values.
        #             4. Highlight any specific functions or methods used and their roles.
        #             5. Provide context on how the code fits into a larger application if applicable.]];
        #             end
        #           '';
        #       };
        #       opts = {
        #         visible = false;
        #       };
        #     }
        #     {
        #       role = "user";
        #       content = {
        #         __raw =
        #           unDerscore
        #           # lua
        #           ''
        #                             function _(context)
        #                               local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

        #                               return fmt(
        #                                 [[Please explain this code from buffer %d:

        #             ```%s
        #             %s
        #             ```
        #             ]],
        #                                 context.bufnr,
        #                                 context.filetype,
        #                                 code
        #                               )
        #                             end
        #           '';
        #       };
        #       opts = {
        #         contains_code = true;
        #       };
        #     }
        #   ];
        # };
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
          opts = {
            # show_default_prompt_library = false;
            # show_default_actions = false;
          };
        };
      };
      strategies = {
        chat = {
          adapter = "anthropic";
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
          adapter = "anthropic";
        };
        agent = {
          adapter = "anthropic";
        };
        cmd = {
          adapter = "antropic";
        };
      };
      adapters = {
        deepseek = {
          __raw =
            unDerscore
            # lua
            ''
              function _()
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
          __raw =
            unDerscore
            # lua
            ''
              function _()
                return require("codecompanion.adapters").extend("anthropic", {})
              end
            '';
        };
      };
    };
  };
}
