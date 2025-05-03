{pkgs, ...}: {
  extraPackages = [
    pkgs.neovim-remote
    pkgs.lf
  ];

  keymaps = [
    {
      key = "<leader>fe";
      action = let
        nvimLfConfig = pkgs.writeTextFile {
          name = "nvim-lfrc";
          text = ''
            # Basic settings
            set drawbox
            set icons
            set incsearch

            # Custom mappings for Neovim integration
            map <enter> open
            map <esc> quit
            map q quit
            map <c-x> $nvr --remote-silent -o "$f"
            map <c-v> $nvr --remote-silent -O "$f"
            map <c-t> $nvr --remote-tab-silent "$f"

            # Override default commands for Neovim context
            cmd open ''${{
              case $(file --mime-type "$f" -bL) in
                text/*|application/json) nvr --remote-tab-silent "$f" ;;
                *) xdg-open "$f" ;;
              esac
            }}
          '';
        };
      in ''
        <cmd>TermExec cmd="LF_CONFIG=/dev/null LF_LEVEL=0 ${pkgs.lib.getExe pkgs.lf} -config=${nvimLfConfig} %; exit" direction=float<cr>
      '';
      options = {
        desc = "Open lf file manager";
        silent = true;
        noremap = true;
      };
    }
  ];

  extraConfigLua = ''
    function _G.set_terminal_keymaps()
    	local opts = { buffer = 0 }
    	vim.keymap.set("t", "<A-Esc>", [[<C-\><C-n>]], opts)
    	vim.keymap.set("t", "<A-h>", [[<Cmd>wincmd h<CR>]], opts)
    	vim.keymap.set("t", "<A-j>", [[<Cmd>wincmd j<CR>]], opts)
    	vim.keymap.set("t", "<A-k>", [[<Cmd>wincmd k<CR>]], opts)
    	vim.keymap.set("t", "<A-l>", [[<Cmd>wincmd l<CR>]], opts)
    	vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
    end

    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
  '';

  plugins.toggleterm = {
    enable = true;
    autoLoad = true;
    settings = {
      direction = "float";
      float_opts = {
        border = "curved";
        height = 30;
        width = 130;
      };
      open_mapping = "[[<a-.>]]";
      highlights = {
        FloatBorder = {
          link = "FloatBorder";
        };
      };
    };
  };
}

