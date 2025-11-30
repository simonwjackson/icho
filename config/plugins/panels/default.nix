{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.plugins.panels;
in
{
  options.plugins.panels = {
    enable = lib.mkEnableOption "Window panel management using edgy.nvim";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.vimUtils.buildVimPlugin {
        name = "panels";
        src = ./.;
      };
      description = "The panels plugin package";
    };

    animate = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable panel animations";
    };

    sizes = {
      right = lib.mkOption {
        type = lib.types.float;
        default = 0.381;
        description = "Size ratio for right panel (0.0-1.0)";
      };

      left = lib.mkOption {
        type = lib.types.float;
        default = 0.234;
        description = "Size ratio for left panel (0.0-1.0)";
      };

      bottom = lib.mkOption {
        type = lib.types.float;
        default = 0.381;
        description = "Size ratio for bottom panel (0.0-1.0)";
      };
    };

    keymaps = {
      toggleGitStatus = lib.mkOption {
        type = lib.types.str;
        default = "<leader>gs";
        description = "Keymap to toggle git status panel";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    extraPlugins = [
      cfg.package
      pkgs.vimPlugins.edgy-nvim
    ];

    extraConfigLua = ''
      require('panels').setup({
        animate = ${lib.boolToString cfg.animate},
        sizes = {
          right = ${toString cfg.sizes.right},
          left = ${toString cfg.sizes.left},
          bottom = ${toString cfg.sizes.bottom},
        },
      })

      vim.keymap.set("n", "${cfg.keymaps.toggleGitStatus}", function()
        require('panels').toggle('left')
      end, { desc = "Git: Status" })
    '';
  };
}
