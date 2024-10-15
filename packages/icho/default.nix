{
  lib,
  pkgs,
  root,
  ...
}: let
  nvr = lib.getExe pkgs.neovim-remote;
  nvim = pkgs.lib.getExe pkgs.neovim;
  plugins = pkgs.callPackage ./plugins.nix {};
  treesitter-parsers = pkgs.symlinkJoin {
    name = "treesitter-parsers";
    # Todo: move into nix plugin file as `runtimes`
    paths = [
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
        p.bash
        p.just
        p.javascript
        p.json
        p.lua
        p.markdown
        p.markdown_inline
        p.nix
        p.python
        p.regex
        p.typescript
        p.vim
        p.vimdoc
      ]))
      .dependencies
    ];
  };
  snippets = pkgs.stdenv.mkDerivation {
    name = "snippets";
    src = ../../snippets;

    installPhase = ''
      mkdir -p $out
      cp -r $src/* $out/
    '';
  };
  neovimConfig = pkgs.runCommandNoCC "neovimConfig" {} ''
    mkdir -p $out/nvim/lua
    cat ${../..}/config/init.lua > $out/nvim/init.lua

    cat >> $out/nvim/init.lua <<EOF
      vim.opt.rtp:prepend("${pkgs.awesomeNeovimPlugins.lazy-nvim}")
      require("lazy").setup("plugins", {
        root = vim.fn.stdpath("run") .. "/lazy",
        lockfile = vim.fn.stdpath("run") .. "/lazy/lazy-lock.json", -- lockfile generated after running update.
      })

      -- Add Treesitter Parsers Path
      vim.opt.runtimepath:prepend("${treesitter-parsers}")
      vim.opt.runtimepath:prepend("${pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [p.yaml])}")
    EOF

    ln -s ${plugins}/* $out/nvim/lua
  '';
in
  pkgs.writeShellScriptBin "nvim" ''
    export PATH="$PATH:${pkgs.lib.makeBinPath (import ./get-packages.nix {inherit pkgs;})}"

    ${import ./get-env-vars.nix {inherit pkgs;}}
    ${import ./get-env-files.nix {inherit pkgs;}}

    export VISUAL="${nvr} -cc split --remote-wait +'set bufhidden=wipe'"
    export LUASNIP_SNIPPETS="${snippets}"

    ${nvim} \
      --clean \
      --cmd 'set rtp+=${neovimConfig}/nvim/' \
      -u ${neovimConfig}/nvim/init.lua \
      "$@"
  ''
