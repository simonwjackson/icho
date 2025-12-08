{
  pkgs,
  lib,
  ...
}: {
  plugins.conform-nvim = {
    enable = true;

    settings = {
      format_on_save = {
        lsp_format = "fallback";
        timeout_ms = 500;
        async = false;
      };

      formatters_by_ft = {
        # Web
        javascript = {
          __unkeyed-1 = "biome";
          __unkeyed-2 = "prettierd";
          __unkeyed-3 = "prettier";
          timeout_ms = 2000;
          stop_after_first = true;
        };
        typescript = {
          __unkeyed-1 = "biome";
          __unkeyed-2 = "prettierd";
          __unkeyed-3 = "prettier";
          timeout_ms = 2000;
          stop_after_first = true;
        };
        svelte = ["prettierd"];
        css = ["prettierd"];
        html = ["prettierd"];

        # Data formats
        json = {
          __unkeyed-1 = "biome";
          __unkeyed-2 = "jq";
          stop_after_first = true;
        };
        yaml = ["prettierd"];

        # Shell
        bash = ["shfmt"];
        sh = ["shfmt"];
        zsh = ["shfmt"];

        # Languages
        python = ["ruff_format" "ruff_organize_imports"];
        lua = ["stylua"];
        nix = ["alejandra"];
        cpp = ["clang_format"];
        elm = ["elm_format"];
        just = ["just"];

        # Universal cleanup for all files
        "_" = [
          "squeeze_blanks"
          "trim_whitespace"
          "trim_newlines"
        ];
      };

      log_level = "warn";
      notify_on_error = false;
      notify_no_formatters = false;

      formatters = {
        # Web
        prettierd.command = lib.getExe pkgs.prettierd;
        biome.command = lib.getExe pkgs.biome;

        # Data formats
        jq.command = lib.getExe pkgs.jq;

        # Shell
        shfmt.command = lib.getExe pkgs.shfmt;

        # Languages
        ruff_format.command = lib.getExe pkgs.ruff;
        ruff_organize_imports.command = lib.getExe pkgs.ruff;
        stylua.command = lib.getExe pkgs.stylua;
        alejandra.command = lib.getExe pkgs.alejandra;
        just.command = lib.getExe pkgs.just;

        # Universal
        squeeze_blanks.command = lib.getExe' pkgs.coreutils "cat";
      };
    };
  };
}
