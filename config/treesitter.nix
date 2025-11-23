{pkgs, ...}: {
  plugins.ts-context-commentstring.enable = true;
  plugins.ts-autotag.enable = true;
  plugins.ts-comments.enable = true;

  plugins.treesitter-textobjects = {
    enable = true;
    settings = {
      move = {
        enable = true;
        set_jumps = true;
        goto_next_start = {
          "]f" = {
            query = "@function.outer";
            desc = "Next function start";
          };
          "]c" = {
            query = "@conditional.outer";
            desc = "Next conditional start";
          };
          "]l" = {
            query = "@loop.outer";
            desc = "Next loop start";
          };
          "]o" = {
            query = "@class.outer";
            desc = "Next class start";
          };
        };
        goto_next_end = {
          "]F" = {
            query = "@function.outer";
            desc = "Next function end";
          };
          "]C" = {
            query = "@conditional.outer";
            desc = "Next conditional end";
          };
          "]L" = {
            query = "@loop.outer";
            desc = "Next loop end";
          };
          "]O" = {
            query = "@class.outer";
            desc = "Next class end";
          };
        };
        goto_previous_start = {
          "[f" = {
            query = "@function.outer";
            desc = "Previous function start";
          };
          "[c" = {
            query = "@conditional.outer";
            desc = "Previous conditional start";
          };
          "[l" = {
            query = "@loop.outer";
            desc = "Previous loop start";
          };
          "[o" = {
            query = "@class.outer";
            desc = "Previous class start";
          };
        };
        goto_previous_end = {
          "[F" = {
            query = "@function.outer";
            desc = "Previous function end";
          };
          "[C" = {
            query = "@conditional.outer";
            desc = "Previous conditional end";
          };
          "[L" = {
            query = "@loop.outer";
            desc = "Previous loop end";
          };
          "[O" = {
            query = "@class.outer";
            desc = "Previous class end";
          };
        };
      };
      select = {
        enable = true;
        lookahead = true;
        keymaps = {
          "af" = {
            query = "@function.outer";
            desc = "Select outer function";
          };
          "if" = {
            query = "@function.inner";
            desc = "Select inner function";
          };
          "ac" = {
            query = "@conditional.outer";
            desc = "Select outer conditional";
          };
          "ic" = {
            query = "@conditional.inner";
            desc = "Select inner conditional";
          };
          "al" = {
            query = "@loop.outer";
            desc = "Select outer loop";
          };
          "il" = {
            query = "@loop.inner";
            desc = "Select inner loop";
          };
        };
      };
    };
  };

  plugins.treesitter-refactor = {
    enable = true;
    # smartRename.enable = true;
    settings = {
      navigation.enable = true;
      highlight_current_scope.enable = false;
      highlight_definitions.enable = false;
    };
  };

  plugins.treesitter = {
    enable = true;
    settings.highlight.enable = true;

    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      astro
      jsonc
      bash
      c
      cpp
      css
      dart
      dockerfile
      elixir
      elm
      erlang
      fish
      go
      graphql
      haskell
      html
      http
      ini
      java
      javascript
      json
      just
      latex
      liquid
      lua
      make
      markdown
      markdown_inline
      nix
      php
      proto
      python
      regex
      ruby
      rust
      scss
      sql
      svelte
      toml
      tsx
      typescript
      typst
      vim
      vimdoc
      vue
      xml
      yaml
      zig
    ];
  };
}
