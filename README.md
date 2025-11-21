# Slim Ops Neovim Configuration

A simple Neovim setup that tries to balance minimal complexity with useful functionality for daily coding tasks.

## Approach

This configuration follows a straightforward philosophy:

- **Manual LSP Installation**: Skips plugin managers like Mason in favor of manual server installation for predictability
- **Stability Over Features**: Prioritizes working reliably over having the latest features
- **Standard Keybindings**: Uses familiar Vim conventions where possible
- **Multi-Language Support**: Includes LSP support for common programming languages

## What's Included

### Basic UI
- Catppuccin colorscheme
- Lualine status line
- Barbar for buffer tabs
- Simple indent guides

### File Navigation
- NvimTree file explorer
- Telescope fuzzy finder
- Basic Git status in file tree

### Development Tools
- LSP support for: Python, Go, Ruby, Lua, TypeScript/JavaScript, HTML, CSS, JSON, YAML, Terraform, Docker, Helm
- GitHub Copilot integration
- Treesitter syntax highlighting
- Basic autocompletion

### Git Integration
- Gitsigns for git indicators
- Neogit for git operations
- Line blame information

### Utilities
- Floating terminal (ToggleTerm)
- Claude Code integration
- Markdown preview
- Comment toggling and text manipulation

## Installation

### Prerequisites
```bash
# Neovim 0.9+ required
nvim --version
```

### Setup
1. **Clone this configuration:**
   ```bash
   git clone <your-repo-url> ~/.config/nvim
   cd ~/.config/nvim
   ```

2. **Install LSP servers:**
   ```bash
   chmod +x install-lsp-servers.sh
   ./install-lsp-servers.sh
   ```

3. **Launch Neovim:**
   ```bash
   nvim
   ```
   Lazy.nvim will install plugins on first run.

## Plugin Management & Stability

This configuration uses `lazy-lock.json` to pin plugin versions and prevent automatic updates that could introduce breaking changes.

### Best Practices:
- **Keep `lazy-lock.json` in your repo** - this ensures consistent plugin versions
- **Manual updates only** - plugins won't update automatically
- **Test before committing** - always test after updating lazy-lock.json

### Updating Plugins:
```vim
:Lazy update    " Update plugins and lazy-lock.json
:Lazy restore   " Restore to lazy-lock.json versions
```

After running `:Lazy update`, test everything thoroughly before committing the updated `lazy-lock.json`.

## Keybindings

### Leader Key: `;` (semicolon)

### Essential Operations
| Key | Action |
|-----|--------|
| `;w` | Save file |
| `;q` | Quit |
| `;;` | Save and quit (ZZ) |
| `<Esc>` | Clear search highlighting |

### File Navigation
| Key | Action |
|-----|--------|
| `;e` | Toggle file explorer |
| `;j` | Find files (Telescope) |
| `;k` | Live grep search |
| `;l` | Recent files |

### Buffer/Tab Management
| Key | Action |
|-----|--------|
| `<Tab>` / `<S-Tab>` | Next/previous buffer |
| `;bd` | Close buffer |
| `;bp` | Pin buffer |
| `;1` - `;5` | Jump to buffer 1-5 |

### LSP Features
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Show references |
| `K` | Hover documentation |
| `<Space>ca` | Code actions |
| `<Space>rn` | Rename symbol |
| `<Space>f` | Format code |
| `<Space>d` | Show diagnostics |

### Git Operations
| Key | Action |
|-----|--------|
| `;gg` | Open Neogit |
| `;gc` | Git commit |
| `;hp` | Preview hunk |
| `;hs` | Stage hunk |
| `]c` / `[c` | Next/previous hunk |

### Terminal & AI
| Key | Action |
|-----|--------|
| `;t` | Toggle terminal |
| `;a` | **Claude Code integration** |
| `<Ctrl-\>` | Toggle terminal (from terminal mode) |

## LSP Server Installation

The configuration supports these languages out of the box:

- **Python**: `pip install pyright`
- **Go**: `go install golang.org/x/tools/gopls@latest`
- **Ruby**: `gem install solargraph`
- **Lua**: `brew install lua-language-server` (macOS)
- **TypeScript/JavaScript**: `npm install -g typescript typescript-language-server`
- **HTML/CSS/JSON**: `npm install -g vscode-langservers-extracted`
- **Tailwind CSS**: `npm install -g @tailwindcss/language-server`
- **YAML**: `npm install -g yaml-language-server`

Run the included `install-lsp-servers.sh` script to install all servers automatically.

## Configuration Structure

```
~/.config/nvim/
├── init.lua                 # Main configuration file
├── lua/config/
│   └── keymaps.lua         # Centralized keybinding definitions
├── install-lsp-servers.sh  # LSP server installation script
└── lazy-lock.json          # Plugin version lock file
```

## Customization

### Adding New LSP Servers
Edit `init.lua` around line 240-330 to add new language servers:

```lua
lspconfig.your_server.setup({
  capabilities = capabilities,
  -- server-specific settings
})
```

### Modifying Keybindings
All keybindings are centralized in `lua/config/keymaps.lua` for easy customization.

### Theme Customization
Change the colorscheme by modifying line 488 in `init.lua`:
```lua
vim.cmd("colorscheme your-preferred-theme")
```

## Troubleshooting

### LSP Not Working
1. Check if LSP servers are installed: run the installation script
2. Use `:LspInfo` to see server status
3. Verify your project has proper config files (e.g., `go.mod`, `package.json`)

### Plugin Issues
- Use `:Lazy restore` to revert to known working versions
- Check `:checkhealth` for common problems

### Theme Issues  
- Ensure your terminal supports true colors
- Try `:set termguicolors` if colors look wrong
