{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.plugins.claude-instances;
in
{
  options.plugins.claude-instances = {
    enable = lib.mkEnableOption "Claude Code multi-instance management";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.vimUtils.buildVimPlugin {
        name = "claude-instances";
        src = ./.;
      };
      description = "The claude-instances plugin package";
    };

    terminalCmd = lib.mkOption {
      type = lib.types.str;
      default = "${lib.getExe pkgs.bun} x @anthropic-ai/claude-code --dangerously-skip-permissions";
      description = "Command to run Claude Code CLI";
    };

    floatWidth = lib.mkOption {
      type = lib.types.float;
      default = 0.8;
      description = "Float window width as percentage of screen (0.0-1.0)";
    };

    floatHeight = lib.mkOption {
      type = lib.types.float;
      default = 0.8;
      description = "Float window height as percentage of screen (0.0-1.0)";
    };

    border = lib.mkOption {
      type = lib.types.str;
      default = "rounded";
      description = "Border style for float windows";
    };

    background = lib.mkOption {
      type = lib.types.str;
      default = "#1a1b26";
      description = "Background color for terminal windows";
    };

    keymaps = {
      new = lib.mkOption {
        type = lib.types.str;
        default = "<leader>an";
        description = "Keymap to spawn new instance";
      };

      list = lib.mkOption {
        type = lib.types.str;
        default = "<leader>al";
        description = "Keymap to list instances";
      };

      next = lib.mkOption {
        type = lib.types.str;
        default = "<C-n>";
        description = "Keymap to go to next instance (in Claude terminal)";
      };

      prev = lib.mkOption {
        type = lib.types.str;
        default = "<C-p>";
        description = "Keymap to go to previous instance (in Claude terminal)";
      };

      close = lib.mkOption {
        type = lib.types.str;
        default = "<leader>ax";
        description = "Keymap to close current instance";
      };

      closeAll = lib.mkOption {
        type = lib.types.str;
        default = "<leader>aX";
        description = "Keymap to close all instances";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    extraPackages = [ pkgs.bun ];

    extraPlugins = [
      cfg.package
      pkgs.vimPlugins.toggleterm-nvim
    ];

    highlight.TerminalBackground.bg = cfg.background;

    extraConfigLua = ''
      -- Claude Instances setup
      require('claude-instances').setup({
        terminal_cmd = "${cfg.terminalCmd}",
        float_width = ${toString cfg.floatWidth},
        float_height = ${toString cfg.floatHeight},
        border = "${cfg.border}",
        background = "${cfg.background}",
      })

      local ci = require('claude-instances')

      -- Keymaps
      vim.keymap.set("n", "${cfg.keymaps.new}", function()
        ci.spawn()
      end, { desc = "Claude: New instance" })

      vim.keymap.set("n", "${cfg.keymaps.list}", ci.pick, { desc = "Claude: List instances" })

      -- Cycle instances with configured keys when in a Claude float
      for _, mode in ipairs({"n", "t"}) do
        vim.keymap.set(mode, "${cfg.keymaps.next}", function()
          if ci.current() then
            ci.navigate("next")
          else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("${cfg.keymaps.next}", true, false, true), "n", false)
          end
        end, { desc = "Claude: Next instance" })

        vim.keymap.set(mode, "${cfg.keymaps.prev}", function()
          if ci.current() then
            ci.navigate("prev")
          else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("${cfg.keymaps.prev}", true, false, true), "n", false)
          end
        end, { desc = "Claude: Previous instance" })
      end

      vim.keymap.set("n", "${cfg.keymaps.close}", function()
        local id, data = ci.current()
        if id then
          local display_name = ci.get_display_name(id, data)
          ci.close(id)
          vim.notify("Closed: " .. display_name, vim.log.levels.INFO)
        else
          vim.notify("Not in a Claude instance", vim.log.levels.WARN)
        end
      end, { desc = "Claude: Close current instance" })

      vim.keymap.set("n", "${cfg.keymaps.closeAll}", function()
        local list = ci.list()
        local count = #list
        ci.close_all()
        vim.notify("Closed " .. count .. " instance(s)", vim.log.levels.INFO)
      end, { desc = "Claude: Close all instances" })
    '';
  };
}
