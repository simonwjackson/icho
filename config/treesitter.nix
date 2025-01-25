{pkgs, ...}: {
  plugins.treesitter = {
    enable = true;

    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      bash
      javascript
      json
      just
      lua
      make
      markdown
      markdown_inline
      nix
      python
      regex
      toml
      typescript
      vim
      vimdoc
      xml
      yaml
    ];
  };
}
