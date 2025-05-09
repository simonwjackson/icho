{pkgs, ...}: {
  # Include LuaSnip plugin and related packages
  extraPlugins = with pkgs.vimPlugins; [
    luasnip
    friendly-snippets # Collection of snippets
    # telescope-luasnip-nvim # Telescope integration for snippets
  ];

  # Basic LuaSnip configuration
  extraConfigLua = ''
    -- Load LuaSnip
    local luasnip = require("luasnip")
    local ls = luasnip
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node
    local f = ls.function_node
    local c = ls.choice_node
    local d = ls.dynamic_node
    local fmt = require("luasnip.extras.fmt").fmt
    local rep = require("luasnip.extras").rep
    local conds = require("luasnip.extras.conditions")

    -- Load friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Setup LuaSnip
    luasnip.config.set_config({
      history = true,
      updateevents = "TextChanged,TextChangedI",
      enable_autosnippets = true,
      ext_opts = {
        [require("luasnip.util.types").choiceNode] = {
          active = {
            virt_text = { { "● Choice", "GruvboxOrange" } },
          },
        },
      },
    })

    -- Define custom snippets
    do
      -- Custom condition function to check if buffer name is "agent-input"
      local function buffer_is_agent_input()
        local bufname = vim.fn.expand("%:t")
        return bufname == "agent-input"
      end

      -- Create a condition object from our function
      local agent_input_file = conds.make_condition(buffer_is_agent_input)

      -- Lua snippets
      ls.add_snippets("lua", {
        -- Create a Lua function snippet
        s("fn", fmt(
          [[
          function {}({})
            {}
          end
          ]],
          {
            i(1, "name"),
            i(2, "args"),
            i(3, "-- TODO: implement")
          }
        )),

        -- For loop snippet
        s("for", fmt(
          [[
          for {} = {}, {} do
            {}
          end
          ]],
          {
            i(1, "i"),
            i(2, "1"),
            i(3, "10"),
            i(4, "-- body")
          }
        )),
      })

      -- Nix snippets
      ls.add_snippets("nix", {
        -- Module snippet
        s("mod", fmt(
          [[
          {{ {}, ... }}: {{
            {}
          }}
          ]],
          {
            i(1, "pkgs"),
            i(2, "# module contents")
          }
        )),

        -- Plugin config snippet
        s("plugin", fmt(
          [[
          plugins.{} = {{
            enable = true;
            settings = {{
              {}
            }};
          }};
          ]],
          {
            i(1, "plugin-name"),
            i(2, "# plugin settings")
          }
        )),
      })

      -- Markdown snippets
      ls.add_snippets("markdown", {
        -- Code block snippet
        s("code", fmt(
          [[
          ```{}
          {}
          ```
          ]],
          {
            i(1, "language"),
            i(2, "code")
          }
        )),

        -- Link snippet
        s("link", fmt(
          "[{}]({})",
          {
            i(1, "title"),
            i(2, "url")
          }
        )),
      })

      -- JavaScript/TypeScript snippets
      ls.add_snippets("typescript", {
        -- Arrow function
        s("arrow", fmt(
          "const {} = ({}) => {}",
          {
            i(1, "functionName"),
            i(2, "params"),
            i(3, "{ /* TODO */ }")
          }
        )),
      })

      ls.add_snippets("javascript", {
        -- Arrow function (same as TypeScript)
        s("arrow", fmt(
          "const {} = ({}) => {}",
          {
            i(1, "functionName"),
            i(2, "params"),
            i(3, "{ /* TODO */ }")
          }
        )),
      })

      -- All filetypes
      ls.add_snippets("all", {
        -- Date snippet
        s("date", f(function() return os.date("%Y-%m-%d") end)),

        -- Current filename
        s("filename", f(function() return vim.fn.expand("%:t") end)),

        -- Context Prime snippet (with condition)
        s(
          {
            trig = "context-prime",
            dscr = "Insert a context prime template for agent instructions",
            condition = agent_input_file,
          },
          t({
            "# Context Prime",
            "> Follow the instructions to understand the context of the project.",
            "",
            "<instruction>",
            "## Run the following commands",
            "",
            "```sh",
            "nix run nixpkgs#eza -- --tree --all --git-ignore 2>/dev/null",
            "nix run nixpkgs#eza -- --tree --all ./ai_docs 2>/dev/null",
            "```",
            "",
            "## Read the following files",
            "> Read the files below (if they exist) and nothing else.",
            "> Customize this list based on the project type to include the most relevant configuration and documentation files.",
            "",
            "```",
            "# Overview documentation",
            "README.md",
            "",
            "# Project configuration",
            "# Choose files appropriate for the project type, examples:",
            "# JavaScript/Node: package.json, tsconfig.json",
            "# Python: pyproject.toml, setup.py",
            "# Rust: Cargo.toml",
            "# Go: go.mod, go.sum",
            "# Nix: flake.nix, default.nix",
            "",
            "# Custom project documentation",
            "# docs/architecture.md",
            "# docs/setup.md",
            "```",
            "</instruction>",
            "",
            "<output_requirements>",
            "- Do not provide any response, confirmation, or content summary after reading the file.",
            "- This command is solely to load the file information for future reference in our conversation.",
            "- Proceed silently after completing this task.",
            "</output_requirements>",
          })
        )
      })
    end

    -- Key mappings for snippet navigation
    vim.keymap.set({"i", "s"}, "<C-k>", function()
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      end
    end, { silent = true, desc = "Expand snippet or jump to next placeholder" })

    vim.keymap.set({"i", "s"}, "<C-j>", function()
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      end
    end, { silent = true, desc = "Jump to previous placeholder" })

    vim.keymap.set({"i", "s"}, "<C-l>", function()
      if luasnip.choice_active() then
        luasnip.change_choice(1)
      end
    end, { silent = true, desc = "Cycle through choices" })
  '';

  # Add some keymaps for LuaSnip
  keymaps = [
    {
      key = "<leader>xe";
      action = "<cmd>lua require('luasnip.loaders').edit_snippet_files()<CR>";
      options = {
        desc = "Edit snippets";
      };
    }
    {
      key = "<leader>xr";
      action = "<cmd>lua require('luasnip').reload_file()<CR>";
      options = {
        desc = "Reload snippets";
      };
    }
  ];
}

