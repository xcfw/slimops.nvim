-- lua/config/keymaps.lua
-- Centralized keymaps for all plugins and Neovim functions

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- General keymaps
map('n', '<leader>w', '<cmd>up<cr>', opts)
map('n', '<leader>q', '<cmd>quit<cr>', opts)
map('n', '<leader><leader>', 'ZZ', opts)
map('n', '<Esc>', '<cmd>nohl<cr>', opts)

-- Copy file paths to system clipboard
map('n', '<space>y', '<cmd>let @+ = expand("%")<cr>', opts)  -- Copy relative path
map('n', '<space>Y', '<cmd>let @+ = expand("%:p")<cr>', opts)  -- Copy absolute path

-- Clipboard behavior: specific deletions go to 'd' register (local only, not system clipboard)
map('n', 'dd', '"ddd', opts)  -- Delete line to 'd' register
map('n', 'D', '"dD', opts)    -- Delete to end of line to 'd' register
map('n', 'de', '"dde', opts)  -- Delete to end of word to 'd' register
map('n', 'd$', '"dd$', opts)  -- Delete to end of line to 'd' register
map('n', 'C', '"dC', opts)    -- Change to end of line to 'd' register

-- paste from d register without overwriting it
map('x', '<space>p', '"dp', opts)
map('n', '<space>P', '"dP', opts)

-- nvim-tree keymaps
map('n', '<leader>e', '<cmd>NvimTreeToggle<cr>', opts)

-- Barbar keymaps (tabs/buffers)
map('n', '<Tab>', '<cmd>BufferNext<cr>', opts)
map('n', '<S-Tab>', '<cmd>BufferPrevious<cr>', opts)
map('n', '<leader>bd', '<cmd>BufferClose<cr>', opts)
map('n', '<leader>bp', '<cmd>BufferPin<cr>', opts)
map('n', '<leader>1', '<cmd>BufferGoto 1<cr>', opts)
map('n', '<leader>2', '<cmd>BufferGoto 2<cr>', opts)
map('n', '<leader>3', '<cmd>BufferGoto 3<cr>', opts)
map('n', '<leader>4', '<cmd>BufferGoto 4<cr>', opts)
map('n', '<leader>5', '<cmd>BufferGoto 5<cr>', opts)

-- Telescope keymaps
map('n', '<leader>j', '<cmd>lua require("telescope.builtin").find_files()<cr>', opts)
map('n', '<leader>J', '<cmd>lua require("telescope.builtin").find_files({find_command={"rg","--ignore","--hidden","--files"}})<cr>', opts)
map('n', '<leader>k', '<cmd>lua require("telescope.builtin").live_grep({additional_args={"--hidden"},glob_pattern="!node_modules/*"})<cr>', opts)
map('n', '<leader>K', '<cmd>lua require("telescope.builtin").live_grep({additional_args={"--hidden","--no-ignore"}})<cr>', opts)
map('n', '<leader>l', '<cmd>lua require("telescope.builtin").oldfiles({cwd_only=true})<cr>', opts)
map('n', '<leader>dh', '<cmd>lua require("telescope.builtin").help_tags()<cr>', opts)
map('n', '<leader>ds', '<cmd>lua require("telescope.builtin").lsp_document_symbols()<cr>', opts)
map('n', '<leader>dr', '<cmd>lua require("telescope.builtin").lsp_references()<cr>', opts)

-- Neogit keymaps
map('n', '<leader>g', '<cmd>Neogit<cr>', opts)

-- LSP keymaps
-- Standard go-to keymaps (no leader)
map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)

-- Space as LSP "leader" - organized by function
-- Code actions and refactoring
map('n', '<Space>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
map('n', '<Space>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
map('n', '<Space>f', '<cmd>lua vim.lsp.buf.format({ async = true })<cr>', opts)

-- Diagnostics
map('n', '<Space>d', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
map('n', '<Space>dl', '<cmd>lua vim.diagnostic.setloclist()<cr>', opts)
map('n', '<Space>dq', '<cmd>lua vim.diagnostic.setqflist()<cr>', opts)

-- Navigation (keep bracket style for consistency)
map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)

-- Workspace operations
map('n', '<Space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>', opts)
map('n', '<Space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>', opts)
map('n', '<Space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>', opts)

-- Copilot integration via nvim-cmp
-- Tab/S-Tab for navigating completions (configured in init.lua)
-- Copilot suggestions appear as completion items through copilot-cmp
-- Use Enter to accept, Tab/S-Tab to navigate suggestions

-- Window navigation
map('n', '<C-h>', '<C-w>h', opts)
map('n', '<C-j>', '<C-w>j', opts)
map('n', '<C-k>', '<C-w>k', opts)
map('n', '<C-l>', '<C-w>l', opts)

-- Window resizing
map('n', '<C-Up>', '<cmd>resize +2<cr>', opts)
map('n', '<C-Down>', '<cmd>resize -2<cr>', opts)
map('n', '<C-Left>', '<cmd>vertical resize -2<cr>', opts)
map('n', '<C-Right>', '<cmd>vertical resize +2<cr>', opts)

-- Terminal configurations using toggleterm
-- Floating terminal (;s and C-\)
local floating_terminal = function()
  local Terminal = require('toggleterm.terminal').Terminal
  return Terminal:new({
  direction = 'float',
  float_opts = {
    border = 'curved',
    winblend = 0,
    highlights = {
      border = 'Normal',
      background = 'Normal',
    },
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.8),
  },
  })
end

local claude_terminal = function()
  local Terminal = require('toggleterm.terminal').Terminal
  return Terminal:new({
  id = 2,
  cmd = 'claude code',
  direction = 'horizontal',
  size = function()
    return math.floor(vim.o.lines * 0.7)
  end,
  })
end

-- Terminal keymaps
map('t', '<C-\\>', '<cmd>ToggleTermToggleAll<cr>', opts)
map('t', '<C-h>', '<C-\\><C-n><C-w>h', opts)

map('n', '<leader>s', function() floating_terminal():toggle() end, opts)
map('n', '<leader>a', function() claude_terminal():toggle() end, opts)

-- Gitsigns keymaps
map('n', ']c', '<cmd>Gitsigns next_hunk<cr>', opts)
map('n', '[c', '<cmd>Gitsigns prev_hunk<cr>', opts)

-- Comment.nvim keymaps
-- gcc - toggle line comment
-- gbc - toggle block comment
-- gc{motion} - toggle comment over motion (e.g., gcap for paragraph)
-- gb{motion} - toggle block comment over motion

-- mini.surround keymaps (all use 's' as prefix)
-- sa{motion}{char} - add surround around motion with char (e.g., saw" to surround word with quotes)
-- sd{char} - delete surround char (e.g., sd" to remove quotes)
-- sr{old}{new} - replace surround old with new (e.g., sr"' to change quotes to single quotes)
-- sh - highlight current surround
-- sn/sp - navigate to next/previous surround

-- nvim-lastplace - no keymaps needed (automatic cursor position restoration) 
