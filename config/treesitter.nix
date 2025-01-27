{pkgs, ...}: {
  plugins.ts-context-commentstring.enable = true;
  plugins.ts-autotag.enable = true;
  plugins.ts-comments.enable = true;
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
