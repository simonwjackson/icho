{
  pkgs,
  lib,
  ...
}:
{
  extraPackages = with pkgs; [
    # Nix (nil_ls doesn't provide these checks)
    statix
    deadnix

    # Markdown (no LSP configured)
    markdownlint-cli

    # Docker (no LSP configured)
    hadolint

    # Lua (complementary to lua_ls)
    selene

    # Go (no LSP configured)
    golangci-lint
  ];

  plugins.lint = {
    enable = true;

    lintersByFt = {
      nix = [
        "statix"
        "deadnix"
      ];
      markdown = [ "markdownlint" ];
      dockerfile = [ "hadolint" ];
      lua = [ "selene" ];
      go = [ "golangcilint" ];
    };

    linters = {
      statix = {
        cmd = lib.getExe pkgs.statix;
      };
      deadnix = {
        cmd = lib.getExe pkgs.deadnix;
      };
      markdownlint = {
        cmd = lib.getExe pkgs.markdownlint-cli;
      };
      hadolint = {
        cmd = lib.getExe pkgs.hadolint;
      };
      selene = {
        cmd = lib.getExe pkgs.selene;
      };
      golangcilint = {
        cmd = lib.getExe pkgs.golangci-lint;
      };
    };
  };

  autoCmd = [
    {
      event = [
        "BufWritePost"
        "BufReadPost"
        "InsertLeave"
      ];
      callback.__raw = ''
        function()
          require("lint").try_lint()
        end
      '';
      desc = "Lint on save and insert leave";
    }
  ];
}
