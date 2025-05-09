-- Define custom snippets for LuaSnip
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

-- Define snippets for various filetypes
return {
  -- Lua snippets
  lua = {
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
  },

  -- Nix snippets
  nix = {
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
  },

  -- Markdown snippets
  markdown = {
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
  },

  -- JavaScript/TypeScript snippets
  typescript = {
    -- Arrow function
    s("arrow", fmt(
      "const {} = ({}) => {}",
      {
        i(1, "functionName"),
        i(2, "params"),
        i(3, "{ /* TODO */ }")
      }
    )),
  },

  -- All filetypes
  all = {
    -- Date snippet
    s("date", f(function() return os.date("%Y-%m-%d") end)),
    
    -- Current filename
    s("filename", f(function() return vim.fn.expand("%:t") end)),
  }
}