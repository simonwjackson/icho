{ pkgs, ... }: {
  plugins.treesitter = {
    enable = true;

    settings = {
      highlight.enable = true;
      indent.enable = true;
      incremental_selection = {
        enable = true;
        keymaps = {
          init_selection = "<leader>v";
          node_incremental = "<leader>v";
          scope_incremental = false;
          node_decremental = "<leader>V";
        };
      };
    };

    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      # Core languages
      nix
      lua
      typescript
      tsx
      javascript
      python
      bash
      html
      css
      json
      yaml
      markdown
      markdown_inline

      # Additional languages
      just
      ini
      sql

      # Supporting grammars
      vim
      vimdoc
      query
      regex
      toml
      gitignore
      diff
    ];
  };

  # Treesitter textobjects for selecting functions/classes/etc
  plugins.treesitter-textobjects = {
    enable = true;
    settings = {
      select = {
        enable = true;
        lookahead = true;
        keymaps = {
          "af" = "@function.outer";
          "if" = "@function.inner";
          "ac" = "@class.outer";
          "ic" = "@class.inner";
          "aa" = "@parameter.outer";
          "ia" = "@parameter.inner";
          "ab" = "@block.outer";
          "ib" = "@block.inner";
        };
      };
      move = {
        enable = true;
        set_jumps = true;
        goto_next_start = {
          "]f" = "@function.outer";
          "]c" = "@class.outer";
          "]a" = "@parameter.inner";
        };
        goto_next_end = {
          "]F" = "@function.outer";
          "]C" = "@class.outer";
        };
        goto_previous_start = {
          "[f" = "@function.outer";
          "[c" = "@class.outer";
          "[a" = "@parameter.inner";
        };
        goto_previous_end = {
          "[F" = "@function.outer";
          "[C" = "@class.outer";
        };
      };
      swap = {
        enable = true;
        swap_next = {
          "<leader>sa" = "@parameter.inner";
        };
        swap_previous = {
          "<leader>sA" = "@parameter.inner";
        };
      };
    };
  };

  # Auto-close and auto-rename HTML/JSX tags
  plugins.ts-autotag = {
    enable = true;
  };
}
