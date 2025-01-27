<h3 align="center">
    <img src="./.github/assets/icho.jpg" width="300px"/>
</h3>
<h1 align="center">
    icho | A bespoke neovim workspace. Powered by <a href="https://neovim.io/doc/user/lua.html">lua</a> and <a href="https://nixos.org">nix</a>.
</h1>

<div align="center">
    <img alt="Static Badge" src="https://img.shields.io/badge/nixpkgs-unstable-d2a8ff?style=for-the-badge&logo=NixOS&logoColor=cba6f7&labelColor=161B22">
    <img alt="Static Badge" src="https://img.shields.io/badge/State-Forever_WIP-ff7b72?style=for-the-badge&logo=fireship&logoColor=ff7b72&labelColor=161B22">
    <a href="https://github.com/simonwjackson/icho/pulse">
      <img alt="Last commit" src="https://img.shields.io/github/last-commit/simonwjackson/icho?style=for-the-badge&logo=github&logoColor=D9E0EE&labelColor=302D41&color=9fdf9f"/>
    </a>
    <img alt="Static Badge" src="https://img.shields.io/badge/Powered_by-Endless_nights-79c0ff?style=for-the-badge&logo=nuke&logoColor=79c0ff&labelColor=161B22">
    <a href="https://github.com/simonwjackson/icho/tree/main/LICENSE">
      <img alt="License" src="https://img.shields.io/badge/License-MIT-907385605422448742?style=for-the-badge&logo=agpl&color=DDB6F2&logoColor=D9E0EE&labelColor=302D41">
    </a>
    <a href="https://www.buymeacoffee.com/simonwjackson">
      <img alt="Buy me a coffee" src="https://img.shields.io/badge/Buy%20me%20a%20coffee-grey?style=for-the-badge&logo=buymeacoffee&logoColor=D9E0EE&label=Sponsor&labelColor=302D41&color=ffff99" />
    </a>
</div>

## Features

* 🌿 **AI-Powered Assistance**: Intelligent code completion, AI-driven chat, and context-aware prompts to enhance productivity.
* 🦥 **Enhanced Editing**: Advanced text manipulation, code refactoring tools, and improved syntax highlighting for a smoother editing experience.
* 🏃 **Navigation**: Seamless navigation with LSP integration, bookmark management, and powerful fuzzy finding capabilities.
* 🎨 **Customizable UI**: Distraction-free writing modes, enhanced input dialogs, and improved notifications for a polished user interface.
* 🔧 **Quality of Life**: Utilities for session management, file saving with elevated privileges, and streamlined Git workflows.
* 🛠️ **Language Support**: Comprehensive support for a wide range of programming languages and tools, ensuring a tailored experience for developers.
* 🧩 **Modular Configuration**: A flexible and modular setup, allowing easy customization and extension of the editor to fit individual workflows.

Welcome to my Neovim configuration crafted for Nix.
Feel free to use it as is or extract pieces to help construct your own unique setup.

> [!IMPORTANT]
> This repo is provided as-is and is primarily developed for my own workflows. As such, I offer no guarantees of regular updates or support. Bug fixes and feature enhancements will be implemented at my discretion, and only if they align with my personal use-cases. Feel free to fork the project and customize it to your needs, but please understand my involvement in further development will be intermittent.

## Usage

```{nix}
{
    inputs.icho.url = "github:simonwjackson/icho";
}
```

To utilize this configuration, clone the repo and run the following command from the directory:

```
nix run .#
```

or

```
nix run github:simonwjackson/icho
```

## Plugins

This configuration includes a variety of plugins:

### AI

- **supermaven-nvim**: AI code completion with customizable keymaps and conditions.
- **avante**: AI-powered plugin (specific functionality not detailed in the config).

### Keyboard

- **better-escape**: Improved escape key mappings with customizable timeout and mappings.

### HTTP

- **kulala**: HTTP client with debug options, environment scoping, and custom icons.
- **rest**: REST client for Neovim.

### UI

- **otter**: UI plugin (specific functionality not detailed in the config).
- **dressing**: Enhanced UI for input and select dialogs.
- **zen-mode**: Distraction-free writing mode with customizable window settings.
- **noice**: Improved UI for notifications, messages, and popup menus.

### Quality of Life

- **vim-suda**: Allows saving files with sudo privileges.

### Editing
- **vim-matchup**: Enhanced match-up functionality with Treesitter support.
- **repeat**: Repeat plugin commands with `.`.

### Syntax
- **todo-comments**: Highlight and manage TODO comments.
- **typescript-tools**: TypeScript language support.
- **tailwind-tools**: Tailwind CSS utilities.
- **scope**: Scope management for syntax highlighting.
- **smear-cursor**: Smooth cursor animations.
- **refactoring**: Code refactoring tools with Telescope integration.
- **qmk**: QMK firmware configuration support.
- **lspsaga**: Enhanced LSP UI.
- **nvim-surround**: Surround text with brackets, quotes, etc.

### Navigation
- **marks**: Manage and navigate marks.
- **navbuddy**: Navigation sidebar with LSP integration.
- **lazydev**: Lazy development tools with custom runtime settings.

### Utilities
- **helpview**: Enhanced help viewer.
- **direnv**: Environment variable management.
- **git-worktree**: Git worktree management.
- **glance**: Quick navigation and preview.
- **improved-search**: Enhanced search functionality.
- **auto-session**: Automatic session management.
- **comment**: Comment toggling and management.
- **firenvim**: Embed Neovim in the browser.
- **lazygit**: Git integration with LazyGit.
- **grug-far**: Search and replace functionality.

## Plugin Updates

#### all

```shell
nix flake update
```

## Repository Structure

The repository is organized into a modular structure for managing Neovim configurations using Nix. Key components include:

- **config/**: Contains modular configuration files for Neovim plugins, LSP, UI, and utilities. Each file is dedicated to a specific plugin or feature, making it easy to customize or extend.
- **flake.nix**: The main Nix flake configuration, defining the Neovim environment and its dependencies.
- **flake.lock**: Ensures reproducible builds by locking dependency versions.
- **README.md**: Documentation for the repository, including setup instructions and plugin details.

This structure is designed for flexibility, allowing users to pick and choose components for their own Neovim setups.

## Language Support

The repository includes support for the following programming languages and tools:

- Bash
- C
- C++
- CSS
- Dart
- Dockerfile
- Elixir
- Elm
- Erlang
- Fish
- Go
- GraphQL
- Haskell
- HTML
- INI
- Java
- JavaScript
- JSON
- Just
- LaTeX
- Lua
- Make
- Markdown
- Nix
- PHP
- Protocol Buffers (Proto)
- Python
- Regular Expressions (Regex)
- Ruby
- Rust
- SCSS
- SQL
- Svelte
- TOML
- TSX
- TypeScript
- Typst
- Vim
- Vimdoc
- Vue
- XML
- YAML
- Zig

## License

> The files and scripts in this repository are licensed under the MIT License, which is a very
> permissive license allowing you to use, modify, copy, distribute, sell, give away, etc. the software.
> In other words, do what you want with it. The only requirement with the MIT License is that the license
> and copyright notice must be provided with the software.
