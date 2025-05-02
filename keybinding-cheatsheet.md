# icho Keybinding Cheatsheet

This cheatsheet provides a comprehensive reference for all keybindings in icho. The default leader key is `<Space>`.

## Navigation

| Keybinding | Description |
|------------|-------------|
| `<A-C-l>` | Next Tab |
| `<A-C-h>` | Previous Tab |
| `<A-C-j>` | Next Buffer |
| `<A-C-k>` | Previous Buffer |
| `<A-h>` | Navigate to left window |
| `<A-j>` | Navigate to window below |
| `<A-k>` | Navigate to window above |
| `<A-l>` | Navigate to right window |
| `<leader>w` | Window commands (prefixes with `<C-w>`) |
| `s` | Flash (jump to location) |

### Telescope (File Finding & Search)

| Keybinding | Description |
|------------|-------------|
| `<leader>ff` | Find files |
| `<leader>fg` | Find all files (including hidden) |
| `<leader>fw` | Live grep (search in files) |
| `<leader>fo` | Find recently opened files |

## Editing

| Keybinding | Description |
|------------|-------------|
| `<C-s>` | Save file |
| `jk` | Enter Insert mode (when in Normal mode) |
| `kl` | Exit to Normal mode (from Insert mode) |
| `<leader>S` | Search and Replace |

### Code Completion (Supermaven)

| Keybinding | Description |
|------------|-------------|
| `<Tab>` | Accept suggestion |
| `<C-]>` | Clear suggestion |
| `<C-j>` | Accept word |

## AI Features

### Claude Code

TODO

### Code Companion

| Keybinding | Description |
|------------|-------------|
| `<leader>af` | AI Actions: Fix |
| `<leader>ag` | AI Actions: Git Commit Message |
| `<leader>ac` | AI Actions: nvim cmd |
| `<leader>al` | AI Actions: Show |
| `<C-Space>` | AI Chat: Toggle |
| `<C-S-Space>` | AI Chat: Toggle (alternative) |
| `<leader>at` | AI Chat: Toggle (alternative) |
| `<leader>ap` | AI Chat: Prompt |
| `<leader>an` | AI Chat: New |
| `ga` | AI Chat: Add |

#### In Chat Mode

| Keybinding | Description |
|------------|-------------|
| `<C-s>` / `<C-Enter>` / `<Enter>` | Send (Normal mode) |
| `<C-s>` / `<C-Enter>` | Send (Insert mode) |
| `<C-c>` | Close |

## Terminal & Task Management

| Keybinding | Description |
|------------|-------------|
| `<A-.>` | Toggle terminal |
| `<C-t>` | Open new tab with terminal |
| `<leader>p` | Tmux session switcher |
| `<leader>fe` | Open lf file manager |

### Terminal Mode Keybindings

| Keybinding | Description |
|------------|-------------|
| `<A-Esc>` | Exit terminal mode |
| `<A-h>` | Navigate to left window from terminal |
| `<A-j>` | Navigate to window below from terminal |
| `<A-k>` | Navigate to window above from terminal |
| `<A-l>` | Navigate to right window from terminal |
| `<C-w>` | Window command from terminal |

### Overseer (Task Runner)

| Keybinding | Description |
|------------|-------------|
| `<leader>to` | Overseer: Task Overview |
| `<leader>tl` | Overseer: Task List (or new cmd) |
| `<leader>tq` | Overseer: Previous Task Action |
| `<leader>tr` | Overseer: Restart Last Action |
| `<leader>tp` | Overseer: Preview Last Action |
| `<leader>ta` | Overseer: Task Actions |
| `<leader>tc` | Overseer: Run arbitrary command |

## Git Operations

| Keybinding | Description |
|------------|-------------|
| `<leader>gg` | LazyGit |
| `<leader>gw` | Git Worktrees |
| `<leader>gc` | Git commits |
| `<leader>gs` | Git status |

## UI Control

| Keybinding | Description |
|------------|-------------|
| `<A-m>` | Toggle zen mode |
