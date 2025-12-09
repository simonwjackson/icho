{ pkgs, ... }:
{
  plugins.dap = {
    enable = true;
    signs = {
      dapBreakpoint = {
        text = "";
        texthl = "DiagnosticError";
      };
      dapBreakpointCondition = {
        text = "";
        texthl = "DiagnosticWarn";
      };
      dapLogPoint = {
        text = "";
        texthl = "DiagnosticInfo";
      };
      dapStopped = {
        text = "";
        texthl = "DiagnosticOk";
        linehl = "Visual";
      };
      dapBreakpointRejected = {
        text = "";
        texthl = "DiagnosticError";
      };
    };
  };

  plugins.dap-virtual-text = {
    enable = true;
  };

  extraPlugins = with pkgs.vimPlugins; [
    nvim-dap-vscode-js
    one-small-step-for-vimkind
  ];

  extraPackages = with pkgs; [
    vscode-js-debug
  ];

  extraConfigLua = ''
    local dap = require("dap")

    ---------------------------------------------------------------------------
    -- TypeScript/JavaScript (Bun & Chrome)
    ---------------------------------------------------------------------------
    require("dap-vscode-js").setup({
      debugger_path = "${pkgs.vscode-js-debug}",
      adapters = { "pwa-node", "pwa-chrome" },
    })

    -- Node/Bun configurations
    for _, lang in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
      dap.configurations[lang] = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file (Node)",
          program = "''${file}",
          cwd = "''${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file (Bun)",
          program = "''${file}",
          cwd = "''${workspaceFolder}",
          runtimeExecutable = "bun",
          runtimeArgs = { "run" },
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach to process",
          processId = require("dap.utils").pick_process,
          cwd = "''${workspaceFolder}",
        },
        {
          type = "pwa-chrome",
          request = "launch",
          name = "Launch Chrome",
          url = "http://localhost:3000",
          webRoot = "''${workspaceFolder}",
        },
      }
    end

    ---------------------------------------------------------------------------
    -- Neovim Lua (one-small-step-for-vimkind)
    ---------------------------------------------------------------------------
    dap.adapters.nlua = function(callback, config)
      callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
    end

    dap.configurations.lua = {
      {
        type = "nlua",
        request = "attach",
        name = "Attach to running Neovim instance",
      },
    }
  '';

  keymaps = [
    # Breakpoints
    { key = "<leader>db"; action.__raw = "function() require('dap').toggle_breakpoint() end"; options.desc = "Toggle breakpoint"; }
    { key = "<leader>dB"; action.__raw = "function() require('dap').set_breakpoint(vim.fn.input('Condition: ')) end"; options.desc = "Conditional breakpoint"; }
    { key = "<leader>dl"; action.__raw = "function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log message: ')) end"; options.desc = "Log point"; }

    # Execution
    { key = "<leader>dc"; action.__raw = "function() require('dap').continue() end"; options.desc = "Continue"; }
    { key = "<leader>ds"; action.__raw = "function() require('dap').step_over() end"; options.desc = "Step over"; }
    { key = "<leader>di"; action.__raw = "function() require('dap').step_into() end"; options.desc = "Step into"; }
    { key = "<leader>do"; action.__raw = "function() require('dap').step_out() end"; options.desc = "Step out"; }

    # Session
    { key = "<leader>dr"; action.__raw = "function() require('dap').repl.toggle() end"; options.desc = "Toggle REPL"; }
    { key = "<leader>dq"; action.__raw = "function() require('dap').terminate() end"; options.desc = "Terminate"; }
    { key = "<leader>dR"; action.__raw = "function() require('dap').restart() end"; options.desc = "Restart"; }

    # Neovim Lua debugging
    { key = "<leader>dL"; action.__raw = "function() require('osv').launch({ port = 8086 }) end"; options.desc = "Launch Lua debugger"; }
  ];
}
