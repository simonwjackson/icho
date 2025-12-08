{
  keymaps = [
    { key = "<A-h>"; action = "<Cmd>wincmd h<CR>"; options.desc = "Window left"; }
    { key = "<A-j>"; action = "<Cmd>wincmd j<CR>"; options.desc = "Window down"; }
    { key = "<A-k>"; action = "<Cmd>wincmd k<CR>"; options.desc = "Window up"; }
    { key = "<A-l>"; action = "<Cmd>wincmd l<CR>"; options.desc = "Window right"; }
  ];

  extraConfigLua = ''
    -- Darken helper function
    local function darken(hex, factor)
      factor = factor or 0.85
      hex = hex:gsub("#", "")
      local r = math.floor(tonumber(hex:sub(1, 2), 16) * factor)
      local g = math.floor(tonumber(hex:sub(3, 4), 16) * factor)
      local b = math.floor(tonumber(hex:sub(5, 6), 16) * factor)
      return string.format("#%02x%02x%02x", r, g, b)
    end

    -- Set terminal background to match tabline (darker)
    local function set_terminal_bg()
      local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
      if normal_bg then
        local darker_bg = darken(string.format("#%06x", normal_bg), 0.85)
        vim.api.nvim_set_hl(0, "TerminalBg", { bg = darker_bg })
      end
    end

    set_terminal_bg()

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_terminal_bg,
      group = vim.api.nvim_create_augroup("TerminalBg", { clear = true }),
    })

    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set("t", "<A-Esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "<A-h>", [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set("t", "<A-j>", [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set("t", "<A-k>", [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set("t", "<A-l>", [[<Cmd>wincmd l<CR>]], opts)

      -- Apply darker background to terminal
      vim.wo.winhighlight = "Normal:TerminalBg"
    end

    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
  '';
}
