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
| `;J` | Find files (including hidden/ignored) |
| `;k` | Live grep search with args |
| `;f` | Live grep (including hidden/ignored) |
| `;l` | Recent files |

#### Advanced Live Grep Usage (`;k`)

The live grep search supports ripgrep arguments directly in the prompt for powerful filtering:

**Filter by file type (`-t`):**
```
your_search_term -t lua          # Search only in Lua files
your_search_term -t py           # Search only in Python files
your_search_term -t go           # Search only in Go files
your_search_term -t js           # Search only in JavaScript files
your_search_term -t ts           # Search only in TypeScript files
your_search_term -t yaml         # Search only in YAML files
your_search_term -t json         # Search only in JSON files
your_search_term -t html         # Search only in HTML files
your_search_term -t css          # Search only in CSS files
your_search_term -t tf           # Search only in Terraform files
your_search_term -t docker       # Search only in Dockerfiles
your_search_term -t ruby         # Search only in Ruby files
your_search_term -t markdown     # Search only in Markdown files
```

**Filter by glob pattern (`-g`):**
```
your_search_term -g "*.lua"              # Search in all .lua files
your_search_term -g "lua/config/*.lua"   # Search in specific directory
your_search_term -g "*.{lua,vim}"        # Search in multiple extensions
```

**Exclude files (`-g !pattern`):**
```
your_search_term -g "!test/*"            # Exclude test directories
your_search_term -g "!*_test.go"         # Exclude Go test files
your_search_term -g "!*.min.js"          # Exclude minified files
```

**Combine multiple filters:**
```
your_search_term -t lua -g "!test/*"     # Lua files excluding tests
function -g "*.lua" -g "*.vim"           # Search in .lua and .vim files
error -t py -g "!venv/*"                 # Python files excluding virtualenv
```

**Common file types available:** `ada`, `asm`, `awk`, `c`, `cpp`, `cs`, `css`, `dart`, `docker`, `go`, `html`, `java`, `js`, `json`, `kotlin`, `lua`, `markdown`, `php`, `py`, `ruby`, `sass`, `sh`, `sql`, `tf`, `toml`, `ts`, `xml`, `yaml`

**Run `rg --type-list` in terminal to see all available file types.**

### Buffer/Tab Management
| Key | Action |
|-----|--------|
| `<Tab>` | Switch to alternate buffer |
| `<S-Tab>` | Next buffer |
| `<M-1>` - `<M-4>` | Jump to buffer 1-4 |

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
| `]c` / `[c` | Next/previous hunk |
| `;gu` | Open GitHub URL in browser (normal/visual) |

### Terminal & AI
| Key | Action |
|-----|--------|
| `;s` | Toggle floating terminal |
| `<C-\>` | Toggle all terminals |
| `<M-\>` | Terminal picker |
| `;a` | Claude default terminal (normal/visual) |
| `;d` | Claude work terminal (normal/visual) |

### Window Navigation
| Key | Action |
|-----|--------|
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | Navigate between windows |
| `<M-j>` / `<M-k>` | Page down/up (buffer & terminal) |

### Terminal Mode
| Key | Action |
|-----|--------|
| `<C-\>` | Toggle all terminals |
| `lj` | Exit to normal mode |
| `<C-h>` | Move to left window |

### Clipboard Operations
| Key | Action |
|-----|--------|
| `<Space>y` | Copy relative file path |
| `<Space>Y` | Copy absolute file path |
| `<Space>u` | Copy filename only |
| `<Space>p` | Paste from 'd' register (visual) |
| `<Space>P` | Paste from 'd' register (normal) |
| `dd` / `D` / `de` / `d$` / `C` | Delete to 'd' register (not clipboard) |

### Diagnostics Navigation
| Key | Action |
|-----|--------|
| `[d` / `]d` | Previous/next diagnostic |
| `<Space>d` | Show diagnostic float |
| `<Space>dl` | Diagnostics to location list |
| `<Space>dq` | Diagnostics to quickfix |

### Additional LSP Operations
| Key | Action |
|-----|--------|
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `<Space>wa` | Add workspace folder |
| `<Space>wr` | Remove workspace folder |
| `<Space>wl` | List workspace folders |

### Treesitter Text Selection
| Key | Action |
|-----|--------|
| `;v` | Initialize selection |
| `<CR>` | Increment selection |
| `<BS>` | Decrement selection |

### Comment & Surround (mini.nvim)
| Key | Action |
|-----|--------|
| `gcc` | Toggle line comment |
| `gbc` | Toggle block comment |
| `gc{motion}` | Comment over motion |
| `sa{motion}{char}` | Add surround |
| `sd{char}` | Delete surround |
| `sr{old}{new}` | Replace surround |

### Alignment (mini.align)
| Key | Action |
|-----|--------|
| `ga{motion}` | Align text (use in visual mode) |

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
