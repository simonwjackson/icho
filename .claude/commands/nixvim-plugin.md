# Convert to Nixvim Plugin

Convert inline Neovim configuration to a proper Nixvim plugin module.

## Input
$ARGUMENTS - Plugin name (e.g., "my-plugin") or path to existing config file to convert

## Instructions

You are converting Neovim configuration into a proper Nixvim plugin module. Follow these steps:

### 1. Analyze the Input

If given a file path, read it and identify:
- Plugin name(s) from `extraPlugins`
- Lua code from `extraConfigLua`
- Any keymaps defined
- External packages from `extraPackages`
- Configuration options that should be exposed

If given just a plugin name, ask the user what functionality they want.

### 2. Create Directory Structure

Create the plugin at `config/plugins/{plugin-name}/`:

```
config/plugins/{plugin-name}/
├── default.nix           # Nixvim module with options
└── lua/
    └── {plugin-name}/
        └── init.lua      # Lua module code
```

**IMPORTANT**: The Lua file MUST be at `lua/{plugin-name}/init.lua` for `require('{plugin-name}')` to work.

### 3. Create the Lua Module (`lua/{plugin-name}/init.lua`)

Template:
```lua
-- {Plugin Name}: Brief description
local M = {}

-- Configuration (set via Nix)
M.config = {
  -- Default values here
}

-- Private functions
local function helper()
  -- Implementation
end

-- Public API
function M.some_action()
  -- Implementation
end

-- Setup function (called from Nix)
function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)

  -- Initialize plugin
end

return M
```

### 4. Create the Nix Module (`default.nix`)

Template:
```nix
{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.plugins.{plugin-name};
in
{
  options.plugins.{plugin-name} = {
    enable = lib.mkEnableOption "{Plugin description}";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.vimUtils.buildVimPlugin {
        name = "{plugin-name}";
        src = ./.;
      };
      description = "The {plugin-name} plugin package";
    };

    # Add configuration options here
    someOption = lib.mkOption {
      type = lib.types.str;
      default = "default-value";
      description = "Description of the option";
    };

    # Nested options for keymaps
    keymaps = {
      action1 = lib.mkOption {
        type = lib.types.str;
        default = "<leader>xx";
        description = "Keymap for action1";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # External packages needed
    extraPackages = [ /* pkgs.something */ ];

    # Load the plugin and dependencies
    extraPlugins = [
      cfg.package
      # pkgs.vimPlugins.dependency
    ];

    # Optional: highlight groups
    # highlight.SomeHighlight.bg = "#123456";

    # Setup the plugin
    extraConfigLua = ''
      require('{plugin-name}').setup({
        some_option = "${cfg.someOption}",
      })

      -- Keymaps
      vim.keymap.set("n", "${cfg.keymaps.action1}", function()
        require('{plugin-name}').action1()
      end, { desc = "{Plugin}: Action 1" })
    '';
  };
}
```

### 5. Register the Plugin

Add to `config/default.nix` imports:
```nix
imports = [
  # ... existing imports
  ./plugins/{plugin-name}
];
```

### 6. Enable the Plugin

Show the user how to enable it:
```nix
{
  plugins.{plugin-name} = {
    enable = true;
    someOption = "custom-value";
    keymaps.action1 = "<leader>yy";
  };
}
```

## Option Type Reference

Common Nix option types:
- `lib.types.str` - String
- `lib.types.int` - Integer
- `lib.types.float` - Float (0.0-1.0 for percentages)
- `lib.types.bool` - Boolean
- `lib.types.package` - Nix package
- `lib.types.listOf lib.types.str` - List of strings
- `lib.types.attrsOf lib.types.str` - Attribute set of strings
- `lib.types.nullOr lib.types.str` - Optional string
- `lib.types.enum ["a" "b" "c"]` - Enum

## Checklist

Before finishing, verify:
- [ ] Lua file is at `lua/{plugin-name}/init.lua` (NOT at root)
- [ ] `require('{plugin-name}')` matches the directory name
- [ ] All config options are properly escaped in extraConfigLua
- [ ] Keymaps use `${cfg.keymaps.x}` interpolation
- [ ] Plugin is added to `config/default.nix` imports
- [ ] No hardcoded values that should be options
