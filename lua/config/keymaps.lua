-- lua/config/keymaps.lua
-- Centralized keymaps for all plugins and Neovim functions

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- General keymaps
map('n', '<leader>w', '<cmd>up<cr>', opts)
map('n', '<leader>q', '<cmd>BufferClose<cr>', opts)
map('n', '<leader><leader>', 'ZQ', opts)
map('n', '<Esc>', '<cmd>nohl<cr>', opts)

-- Page navigation (works in both buffers and terminal)
local page_nav_modes = { 'n', 't' }
map(page_nav_modes, '<M-j>', '<C-f>', opts)  -- Page down
map(page_nav_modes, '<M-k>', '<C-b>', opts)  -- Page up

-- Precise scroll: PageDown/PageUp scroll viewport by N lines
local page_scroll = 3
local function scroll(key)
  return function()
    local keys = vim.api.nvim_replace_termcodes(page_scroll .. key, true, false, true)
    vim.api.nvim_feedkeys(keys, 'n', false)
  end
end
for _, m in ipairs({'n', 'v', 'i'}) do
  map(m, '<PageDown>', scroll('<C-e>'), opts)
  map(m, '<PageUp>',  scroll('<C-y>'), opts)
end

-- Copy file paths to system clipboard
map('n', '<space>y', '<cmd>let @+ = expand("%")<cr>', opts)  -- Copy relative path
map('n', '<space>Y', '<cmd>let @+ = expand("%:p")<cr>', opts)  -- Copy absolute path
map('n', '<space>u', '<cmd>let @+ = expand("%:t")<cr>', opts)  -- Copy filename only

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
map('n', '<Tab>', '<C-^>', opts)
map('n', '<S-Tab>', '<cmd>BufferNext<cr>', opts)
for i = 1, 4 do
  map('n', '<M-' .. i .. '>', '<cmd>BufferGoto ' .. i .. '<cr>', opts)
end

-- Telescope keymaps
map('n', '<leader>j', function() require("telescope.builtin").find_files() end, opts)
map('n', '<leader>J', function()
    require("telescope.builtin").find_files({
        find_command = {
            "rg",
            "--files",
            "--hidden",
            "--no-ignore",
            -- ⬇️ Explicit Exclusions (Glob Rules) ⬇️
            "--glob", "!**/.git/*",
            "--glob", "!**/node_modules/*",
            "--glob", "!**/target/*",       -- Rust/Caches
            "--glob", "!**/build/*",
            "--glob", "!**/dist/*",
            "--glob", "!**/.cache/*",
            "--glob", "!**/.local/share/*", -- Various hidden caches/data
            "--glob", "!**/.npm/*",
        }
    })
end, opts)
map('n', '<leader>k', function() require("telescope").extensions.live_grep_args.live_grep_args() end, opts)
map('n', '<leader>K', function()
  require("telescope").extensions.live_grep_args.live_grep_args({
    vimgrep_arguments = {
      "rg", "--color=never", "--no-heading", "--with-filename",
      "--line-number", "--column", "--smart-case",
      "--hidden", "--no-ignore", "--unrestricted",
    },
  })
end, opts)
map('n', '<leader>f', function() require("telescope.builtin").live_grep({ additional_args = { "--hidden", "--no-ignore" } }) end, opts)
map('n', '<leader>l', function() require("telescope.builtin").oldfiles({ cwd_only = true }) end, opts)
map('n', '<leader>gh', function() require("telescope.builtin").help_tags() end, opts)
map('n', '<leader>gs', function() require("telescope.builtin").lsp_document_symbols() end, opts)
map('n', '<leader>gr', function() require("telescope.builtin").lsp_references() end, opts)

-- Neogit keymaps
map('n', '<leader>gg', '<cmd>Neogit<cr>', opts)

-- LSP keymaps
-- Standard go-to keymaps (no leader)
map('n', 'gd', vim.lsp.buf.definition, opts)
map('n', 'gD', vim.lsp.buf.declaration, opts)
map('n', 'gi', vim.lsp.buf.implementation, opts)
map('n', 'gr', vim.lsp.buf.references, opts)
map('n', 'K', vim.lsp.buf.hover, opts)

-- Space as LSP "leader" - organized by function
-- Code actions and refactoring
map('n', '<Space>ca', vim.lsp.buf.code_action, opts)
map('n', '<Space>rn', vim.lsp.buf.rename, opts)
map('n', '<Space>f', function()
  require("conform").format({
    lsp_fallback = true,
    timeout_ms = 3000,
  })
end, opts)

-- Diagnostics
map('n', '<Space>d', vim.diagnostic.open_float, opts)
map('n', '<Space>dl', vim.diagnostic.setloclist, opts)
map('n', '<Space>dq', vim.diagnostic.setqflist, opts)

-- Navigation (keep bracket style for consistency)
map('n', '[d', vim.diagnostic.goto_prev, opts)
map('n', ']d', vim.diagnostic.goto_next, opts)

-- Workspace operations
map('n', '<Space>wa', vim.lsp.buf.add_workspace_folder, opts)
map('n', '<Space>wr', vim.lsp.buf.remove_workspace_folder, opts)
map('n', '<Space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)

-- Copilot integration via nvim-cmp
-- Tab/S-Tab for navigating completions (configured in init.lua)
-- Copilot suggestions appear as completion items through copilot-cmp
-- Use Enter to accept, Tab/S-Tab to navigate suggestions

-- Window navigation
for _, key in ipairs({'h', 'j', 'k', 'l'}) do
  map('n', '<C-' .. key .. '>', '<C-w>' .. key, opts)
end

-- Terminal configurations using toggleterm
-- Floating terminal (;s)
local cached_floating_terminal = nil
local function get_floating_terminal()
  if not cached_floating_terminal then
    local Terminal = require('toggleterm.terminal').Terminal
    cached_floating_terminal = Terminal:new({
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
  return cached_floating_terminal
end

-- Terminal keymaps
map('t', ';l', '<C-\\><C-n>', opts)  -- Quick exit to normal mode
map('t', '<C-h>', '<C-\\><C-n><C-w>h', opts)

map('n', '<leader>s', function() get_floating_terminal():toggle() end, opts)

-- Claude terminals (copy path/selection to clipboard, then open terminal)
map('n', '<leader>a', function() require('claude-prompt').open_default() end, opts)
map('v', '<leader>a', function() require('claude-prompt').open_default_visual() end, opts)
map('n', '<leader>d', function() require('claude-prompt').open_work() end, opts)
map('v', '<leader>d', function() require('claude-prompt').open_work_visual() end, opts)

-- Terminal picker (compact dialog, normal mode for hjkl navigation)
map('n', '<M-\\>', function()
  require('telescope').extensions.termfinder.find({
    initial_mode = 'normal',
    layout_strategy = 'vertical',
    layout_config = {
      width = 0.4,
      height = 0.4,
      prompt_position = 'top',
    },
  })
end, opts)

-- Gitsigns hunk keymaps are defined in gitsigns on_attach (init.lua) for proper buffer-scoping

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

-- Base64 encode/decode for selected text
local function get_visual_selection()
  local _, ls, cs = unpack(vim.fn.getpos("'<"))
  local _, le, ce = unpack(vim.fn.getpos("'>"))
  local lines = vim.api.nvim_buf_get_text(0, ls - 1, cs - 1, le - 1, ce, {})
  return table.concat(lines, "\n")
end

local function replace_visual_selection(new_text)
  local _, ls, cs = unpack(vim.fn.getpos("'<"))
  local _, le, ce = unpack(vim.fn.getpos("'>"))
  vim.api.nvim_buf_set_text(0, ls - 1, cs - 1, le - 1, ce, vim.split(new_text, "\n"))
end

local function base64_encode()
  local text = get_visual_selection()
  local handle = io.popen("printf '%s' " .. vim.fn.shellescape(text) .. " | base64")
  if handle then
    local result = handle:read("*a"):gsub("%s+$", "")
    handle:close()
    replace_visual_selection(result)
  end
end

local function base64_decode()
  local text = get_visual_selection()
  local handle = io.popen("printf '%s' " .. vim.fn.shellescape(text) .. " | base64 -d 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()
    if result ~= "" then
      replace_visual_selection(result)
    else
      vim.notify("Invalid base64 input", vim.log.levels.ERROR)
    end
  end
end

map('v', '<leader>b', ':<C-u>lua require("config.keymaps").base64_encode()<CR>', { noremap = true, silent = true, desc = "Base64 encode" })
map('v', '<leader>v', ':<C-u>lua require("config.keymaps").base64_decode()<CR>', { noremap = true, silent = true, desc = "Base64 decode" })

-- Export functions for visual mode keymaps
return {
  base64_encode = base64_encode,
  base64_decode = base64_decode,
}
