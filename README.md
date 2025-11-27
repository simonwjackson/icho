<h3 align="center">
    <img src="./.github/assets/8e7b8cce-3782-42c0-a3eb-62ca1ec649bd_removalai_preview.png" width="300px"/>
</h3>
<h1 align="center">
    icho | A bespoke neovim workspace. Powered by <a href="https://github.com/nix-community/nixvim">nixvim</a>.
</h1>

<div align="center">
    <img alt="Static Badge" src="https://img.shields.io/badge/nixpkgs-unstable-d2a8ff?style=for-the-badge&logo=NixOS&logoColor=cba6f7&labelColor=161B22">
    <img alt="Static Badge" src="https://img.shields.io/badge/State-Forever_WIP-ff7b72?style=for-the-badge&logo=fireship&logoColor=ff7b72&labelColor=161B22">
    <a href="https://github.com/simonwjackson/icho/pulse">
      <img alt="Last commit" src="https://img.shields.io/github/last-commit/simonwjackson/icho?style=for-the-badge&logo=github&logoColor=D9E0EE&labelColor=302D41&color=9fdf9f"/>
    </a>
    <br/>
    <img alt="Static Badge" src="https://img.shields.io/badge/Powered_by-Caffeine-79c0ff?style=for-the-badge&logo=nuke&logoColor=79c0ff&labelColor=161B22">
    <img alt="Static Badge" src="https://img.shields.io/badge/Co--authored_by-Claude-8957e5?style=for-the-badge&logo=anthropic&logoColor=8957e5&labelColor=161B22">
    <a href="https://github.com/simonwjackson/icho/tree/main/LICENSE">
    <br/>
      <img alt="License" src="https://img.shields.io/badge/License-MIT-907385605422448742?style=for-the-badge&logo=agpl&color=DDB6F2&logoColor=D9E0EE&labelColor=302D41">
    </a>
    <a href="https://www.buymeacoffee.com/simonwjackson">
      <img alt="Buy me a coffee" src="https://img.shields.io/badge/Buy%20me%20a%20coffee-grey?style=for-the-badge&logo=buymeacoffee&logoColor=D9E0EE&label=Sponsor&labelColor=302D41&color=ffff99" />
    </a>
</div>

## Features

* 🌿 **AI-Powered Assistance**: Code completion, chat, and context-aware prompts.
* 🦥 **Enhanced Editing**: Code refactoring tools, etc.
* 🏃 **Navigation**: LSP navigation and bookmark management.
* 🎨 **Customizable UI**: Zen mode, refined UI elements, and improved notifications
* 🔧 **Quality of Life**: Auto session management, file saving with elevated privileges, and streamlined Git workflows.
* 🛠️ **Language Support**: Support for a wide range of programming languages and tools, ensuring a tailored experience for developers.
* 🧩 **Modular Configuration**: Files for each plugin.
* 💻 **Automatic Updates**: The project flake updates the plugins nightly.
* 🔑 **Intuitive Keybindings**: Comprehensive set of keybindings for efficient workflow. See the [Keybinding Cheatsheet](./keybinding-cheatsheet.md) for details.

Welcome to my Neovim configuration crafted for Nix.
Feel free to use it as is or extract pieces to help construct your own unique setup.

> [!IMPORTANT]
> This repo is provided as-is and is primarily developed for my own workflows. As such, I offer no guarantees of regular updates or support. Bug fixes and feature enhancements will be implemented at my discretion, and only if they align with my personal use-cases. Feel free to fork the project and customize it to your needs, but please understand my involvement in further development will be intermittent.

## Installation Prerequisites

Before using icho, ensure your system meets the following requirements:

### System Requirements
- **Operating Systems**:
  - Linux: x86_64 and aarch64 architectures
  - macOS: x86_64 (Intel) and aarch64 (Apple Silicon)
  - Windows: Supported via WSL2 (Windows Subsystem for Linux)
    - Recommended: NixOS or any modern Linux distribution
    - [WSL Installation Guide](https://learn.microsoft.com/en-us/windows/wsl/install)
- **Nix**: Using the Nix package manager with flakes enabled
  - Nix version: 2.4 or higher (with flakes feature)
  - [Install Nix](https://nixos.org/download.html)
  - [Enable flakes](https://nixos.wiki/wiki/Flakes#Enable_flakes)
  - [Nix installation on WSL](https://nixos.org/manual/nix/stable/installation/installation)

### Nix Configuration
- Ensure your `nix.conf` has experimental features enabled:
  ```
  experimental-features = nix-command flakes
  ```

### Additional Dependencies
- Git (for cloning the repository)
- Internet connection (for initial setup and updates)

## Usage

```{nix}
{
    inputs.icho.url = "github:simonwjackson/icho";
}
```

To utilize this configuration, clone the repo and run the following command from the directory:

```
nix run
```

or remote:

```
nix run github:simonwjackson/icho
```

## Troubleshooting

Here are solutions to common issues you might encounter when using icho:

### Installation Issues

**Q: I get "error: flake 'github:simonwjackson/icho' does not exist"**
A: This usually indicates connectivity issues or GitHub being unreachable. Check your internet connection and try again. If GitHub is down, wait until service is restored.

**Q: I get "error: experimental feature 'flakes' is disabled"**
A: You need to enable the flakes feature in Nix. Add the following to your `~/.config/nix/nix.conf` file:
```
experimental-features = nix-command flakes
```
Then restart the nix-daemon or your terminal session.

**Q: The installation fails with "Unable to find package" errors**
A: This could be due to a corrupt Nix cache. Try:
```
nix-store --verify --check-contents --repair
```
Then retry the installation.

### Nix-Specific Issues

**Q: I get "warning: unknown warning: EXPERIMENTAL"**
A: This is a normal warning and can be safely ignored. It's just reminding you that you're using experimental features in Nix.

**Q: I see "cannot substitute, path is not valid" errors**
A: This is usually a permission issue. Make sure you have the appropriate permissions for the Nix store. You may need to run:
```
sudo chown -R $(whoami):nixbld /nix
```

**Q: Updates fail with "error: path ... is not valid"**
A: This can happen if your flake.lock file is corrupted. Try:
```
rm flake.lock
nix flake update
```

### Plugin Compatibility Issues

**Q: AI plugins are not working/responding**
A: AI features require external API keys to be set up. Check that you have configured the necessary environment variables. See the AI plugin documentation for specific requirements.

**Q: LSP server for my language doesn't work**
A: Some language servers require additional dependencies. Make sure the corresponding language toolchain is installed on your system outside of icho.

**Q: Plugins keep disappearing after system updates**
A: This can happen if Nix garbage collection removes dependencies. Try adding your icho flake to the nix registry to prevent garbage collection:
```
nix registry add icho github:simonwjackson/icho
```

### Performance Issues

**Q: Neovim is slow to start up**
A: This could be due to multiple factors:
- Too many plugins loading at startup - consider using lazy loading
- Large language servers initializing - configure them to start on demand
- Cold cache - subsequent starts should be faster

**Q: High CPU usage during editing**
A: This is often caused by aggressive LSP or treesitter parsing. Try:
- Disable real-time diagnostics for large files
- Add file size limits to LSP configurations
- Reduce the frequency of certain operations like linting

**Q: Memory usage grows over time**
A: Some plugins might have memory leaks. Identify the problematic plugin by starting with minimal config and adding plugins one by one to isolate the issue.

### Known Limitations

**Q: Some keybindings don't work on my system**
A: Certain key combinations might be intercepted by your OS or terminal emulator. Check for conflicts in your terminal settings or OS keyboard shortcuts.

**Q: AI-powered features give inconsistent results**
A: AI features depend on external services and can vary in quality based on model versions and internet connectivity. This is a limitation of current AI technology.

**Q: Why doesn't icho include plugin X?**
A: icho is maintained as a personal configuration. If a plugin isn't included, it's likely because it doesn't align with the maintainer's workflow. You can always fork the repository and add the plugins you need.

**Q: File-specific settings don't persist between sessions**
A: This is by design - icho prioritizes reproducible configurations via Nix, rather than session-specific settings. Use project-specific configuration files for persistent settings.

## Plugins

This configuration includes a variety of plugins:

### AI

- **supermaven-nvim**: AI code completion with customizable keymaps and conditions.
- **claudecode.nvim**: Deep integration with Claude Code CLI via WebSocket MCP protocol.

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
- **keybinding-cheatsheet.md**: Comprehensive reference for all keybindings organized by category.

This structure is designed for flexibility, allowing users to pick and choose components for their own Neovim setups.

## Language Support

The repo includes support for the following programming languages and tools:

### 🌐 Web Applications
- **Frontend**: HTML, CSS, JavaScript, TypeScript, React (TSX), Vue, Svelte
- **Backend**: Python, Ruby, PHP, Java
- **Data**: SQL, GraphQL
- **Styling**: SCSS, CSS

### 🔧 Systems Development
- **Languages**: C, C++, Rust, Zig
- **Build Tools**: Make, Just
- **Shell**: Bash, Fish

### 📦 DevOps & Configuration
- **Containers**: Dockerfile
- **Package Management**: Nix
- **Data Formats**: JSON, YAML, TOML, XML, Protocol Buffers

### 📚 Documentation & Writing
- **Markup**: Markdown, LaTeX, Typst
- **API Docs**: Vimdoc
- **Regular Expressions**: Regex support for pattern matching

### 🧪 Functional Programming
- **Pure FP**: Haskell, Elm
- **Actor Model**: Erlang, Elixir

## Acknowledgments

This project is co-authored by [Claude](https://claude.ai), who has provided assistance with documentation, configuration improvements, and troubleshooting solutions.

## License

> The files and scripts in this repository are licensed under the MIT License, which is a very
> permissive license allowing you to use, modify, copy, distribute, sell, give away, etc. the software.
> In other words, do what you want with it. The only requirement with the MIT License is that the license
> and copyright notice must be provided with the software.
