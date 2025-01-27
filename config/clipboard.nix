{pkgs, ...}: {
  extraPackages = with pkgs; [
    wl-clipboard
  ];

  # extraPlugins = [
  #   (pkgs.vimUtils.buildVimPlugin {
  #     name = "my-plugin";
  #     src = pkgs.fetchFromGitHub {
  #       owner = "ojroques";
  #       repo = "nvim-osc52";
  #       rev = "04cfaba1865ae5c53b6f887c3ca7304973824fb2";
  #       hash = "sha256:cVivuGzsG2bKfUBklyK7in0C8Xis0aO0pfyOuTol1mU=";
  #     };
  #   })
  # ];

  plugins.nvim-osc52.enable = true;

  extraConfigLua = ''
    require("osc52").setup({
    	max_length = 0, -- Maximum length of selection (0 for no limit)
    	silent = true, -- Disable message on successful copy
    	trim = true, -- Trim surrounding whitespaces before copy
    	tmux_passthrough = true, -- Copy from tmux into vim
    })

    -- yy, yw, yiW, y<motion> will yank to system clipboard. cw or dw won't
    vim.api.nvim_create_autocmd("TextYankPost", {
    	callback = function()
    		if vim.v.event.operator == "y" and vim.v.event.regname == "" then
    			require("osc52").copy_register("0")
    		end
    	end,
    })

    -- dd, dw, diW, d<motion>, D will delete and copy to system clipboard.
    vim.api.nvim_create_autocmd("TextYankPost", {
    	callback = function()
    		if (vim.v.event.operator == "d") and vim.v.event.regname == "" then
    			require("osc52").copy_register("1")
    		end
    	end,
    })
  '';
}
