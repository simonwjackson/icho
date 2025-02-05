{pkgs, ...}: {
  plugins.ts-context-commentstring.enable = true;
  plugins.ts-autotag.enable = true;
  plugins.ts-comments.enable = true;

  plugins.treesitter-textobjects = {
    enable = true;
    move = {
      enable = true;
      setJumps = true;
      gotoNextStart = {
        "]f" = {query = "@function.outer";};
        "]c" = {query = "@conditional.outer";};
        "]l" = {query = "@loop.outer";};
        "]o" = {query = "@class.outer";};
      };
      gotoNextEnd = {
        "]F" = {query = "@function.outer";};
        "]C" = {query = "@conditional.outer";};
        "]L" = {query = "@loop.outer";};
        "]O" = {query = "@class.outer";};
      };
      gotoPreviousStart = {
        "[f" = {query = "@function.outer";};
        "[c" = {query = "@conditional.outer";};
        "[l" = {query = "@loop.outer";};
        "[o" = {query = "@class.outer";};
      };
      gotoPreviousEnd = {
        "[F" = {query = "@function.outer";};
        "[C" = {query = "@conditional.outer";};
        "[L" = {query = "@loop.outer";};
        "[O" = {query = "@class.outer";};
      };
    };
    select = {
      enable = true;
      lookahead = true;
      keymaps = {
        "af" = {query = "@function.outer";};
        "if" = {query = "@function.inner";};
        "ac" = {query = "@conditional.outer";};
        "ic" = {query = "@conditional.inner";};
        "al" = {query = "@loop.outer";};
        "il" = {query = "@loop.inner";};
      };
    };
  };

  plugins.treesitter-refactor = {
    enable = true;
    # smartRename.enable = true;
    navigation.enable = true;
    highlightCurrentScope.enable = true;
    highlightDefinitions.enable = true;
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
      ini
      java
      javascript
      json
      just
      latex
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
