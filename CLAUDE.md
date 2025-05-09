# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build/Test Commands
- Test configuration: `nix flake check`
- Run Neovim with this config: `nix run`
- Update all plugins: `nix flake update`
- Never run `nix run` for this project

## Code Style
- Nix files: Format with Alejandra (`alejandra <file>`)
- Use 2-space indentation for all files
- Follow existing pattern of module imports in .nix files
- No trailing whitespace or extra newlines at EOF
- Keep config modules separate and focused on single functionality
- Variable naming: camelCase for standard variables, PascalCase for types
- When adding new plugins, include them in the appropriate config/ module
- Functions should be added to extraConfigLua with clear documentation
- Keymaps should include a descriptive 'desc' field
- Plugin settings should match standard Nixvim structure

## Git Workflow
- Always `git add` new files