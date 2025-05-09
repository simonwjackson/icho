{
  pkgs,
  lib,
  ...
}: {
  extraPackages = [];

  keymaps = [];

  plugins.conform-nvim = {
    enable = true;
    autoLoad = true;

    settings = {
      format_on_save = {
        lsp_format = "fallback";
        timeout_ms = 500;
      };
      formatters_by_ft = {
        svelte = ["prettierd"];
        css = ["prettierd"];
        html = ["prettierd"];
        json = ["jq"];
        yaml = ["yq"];
        # -- markdown = [ "prettierd" ];
        just = ["just"];
        python = ["isort" "black"];
        awk = ["awk"];
        bash = ["shellcheck" "shellharden" "shfmt"];
        cpp = ["clang_format"];
        elm = ["elm_format"];
        javascript = {
          __unkeyed-1 = "prettierd";
          __unkeyed-2 = "prettier";
          timeout_ms = 2000;
          stop_after_first = true;
        };
        lua = ["stylua"];
        nix = ["alejandra"];
        sh = ["shellcheck" "shellharden" "shfmt"];
        zsh = ["shellcheck" "shellharden" "shfmt"];
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
        awk = {
          command = lib.getExe pkgs.gawk;
        };
        shellcheck = {
          command = lib.getExe pkgs.shellcheck;
        };
        shfmt = {
          command = lib.getExe pkgs.shfmt;
        };
        shellharden = {
          command = lib.getExe pkgs.shellharden;
        };
        squeeze_blanks = {
          command = lib.getExe' pkgs.coreutils "cat";
        };
        prettierd = {
          command = lib.getExe pkgs.prettierd;
        };
        yq = {
          command = lib.getExe pkgs.yq-go;
        };
        jq = {
          command = lib.getExe pkgs.jq;
        };
        just = {
          command = lib.getExe pkgs.just;
        };
        isort = {
          command = lib.getExe pkgs.isort;
        };
        black = {
          command = lib.getExe pkgs.black;
        };
        alejandra = {
          command = lib.getExe pkgs.alejandra;
        };
        stylua = {
          command = lib.getExe pkgs.stylua;
        };
      };
    };
  };
}
