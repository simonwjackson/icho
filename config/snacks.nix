{ pkgs, ... }:
{
  extraPackages = [ pkgs.lazygit ];

  plugins.snacks = {
    enable = true;
    settings = {
      input = {};
      lazygit = {
        win = {
          backdrop = 20;
        };
      };
      picker = {
        enabled = true;
      };
      terminal = {};
      zen = {};
    };
  };

  keymaps = [
    # Find
    { key = "<leader>ff"; action.__raw = "function() Snacks.picker.files({ sort = { field = 'mtime', order = 'desc' } }) end"; options.desc = "Find files (recent first)"; }
    { key = "<leader>fw"; action.__raw = "function() Snacks.picker.grep() end"; options.desc = "Grep"; }
    { key = "<leader>fb"; action.__raw = "function() Snacks.picker.buffers() end"; options.desc = "Buffers"; }
    { key = "<leader>fr"; action.__raw = "function() Snacks.picker.recent() end"; options.desc = "Recent files"; }
    { key = "<leader>f/"; action.__raw = "function() Snacks.picker.grep_buffers() end"; options.desc = "Grep open buffers"; }
    { key = "<leader>fW"; action.__raw = "function() Snacks.picker.grep_word() end"; options.desc = "Grep word"; mode = ["n" "x"]; }

    # Search
    { key = "<leader>s:"; action.__raw = "function() Snacks.picker.command_history() end"; options.desc = "Command history"; }
    { key = "<leader>sc"; action.__raw = "function() Snacks.picker.commands() end"; options.desc = "Commands"; }
    { key = "<leader>sh"; action.__raw = "function() Snacks.picker.help() end"; options.desc = "Help"; }
    { key = "<leader>sk"; action.__raw = "function() Snacks.picker.keymaps() end"; options.desc = "Keymaps"; }
    { key = "<leader>sm"; action.__raw = "function() Snacks.picker.marks() end"; options.desc = "Marks"; }
    { key = "<leader>sr"; action.__raw = "function() Snacks.picker.resume() end"; options.desc = "Resume last picker"; }

    # Git
    { key = "<leader>gg"; action.__raw = "function() Snacks.lazygit() end"; options.desc = "Lazygit"; }
    { key = "<leader>gl"; action.__raw = "function() Snacks.picker.git_log() end"; options.desc = "Git log"; }
    { key = "<leader>gs"; action.__raw = "function() Snacks.picker.git_status() end"; options.desc = "Git status"; }
    { key = "<leader>gf"; action.__raw = "function() Snacks.lazygit.log_file() end"; options.desc = "Lazygit file history"; }
    { key = "<leader>gL"; action.__raw = "function() Snacks.lazygit.log() end"; options.desc = "Lazygit log (cwd)"; }

    # LSP
    { key = "gd"; action.__raw = "function() Snacks.picker.lsp_definitions() end"; options.desc = "Go to definition"; }
    { key = "gr"; action.__raw = "function() Snacks.picker.lsp_references() end"; options.desc = "References"; }
    { key = "gi"; action.__raw = "function() Snacks.picker.lsp_implementations() end"; options.desc = "Implementations"; }
    { key = "<leader>ss"; action.__raw = "function() Snacks.picker.lsp_symbols() end"; options.desc = "LSP symbols"; }
  ];
}
