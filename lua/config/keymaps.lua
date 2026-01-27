-- lua/config/keymaps.lua
-- Centralized keymaps for all plugins and Neovim functions

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- General keymaps
map('n', '<leader>w', '<cmd>up<cr>', opts)
map('n', '<leader>q', '<cmd>BufferClose<cr>', opts)
map('n', '<leader><leader>', 'ZZ', opts)
map('n', '<Esc>', '<cmd>nohl<cr>', opts)

-- Page navigation (works in both buffers and terminal)
local page_nav_modes = { 'n', 't' }
map(page_nav_modes, '<M-j>', '<C-f>', opts)  -- Page down
map(page_nav_modes, '<M-k>', '<C-b>', opts)  -- Page up

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
map('n', '<leader>j', '<cmd>lua require("telescope.builtin").find_files()<cr>', opts)
-- map('n', '<leader>J', '<cmd>lua require("telescope.builtin").find_files({find_command={"rg","--no-ignore","--hidden","--files"}})<cr>', opts)
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
map('n', '<leader>k', '<cmd>lua require("telescope").extensions.live_grep_args.live_grep_args()<cr>', opts)
map('n', '<leader>f', '<cmd>lua require("telescope.builtin").live_grep({additional_args={"--hidden","--no-ignore"}})<cr>', opts)
map('n', '<leader>l', '<cmd>lua require("telescope.builtin").oldfiles({cwd_only=true})<cr>', opts)
map('n', '<leader>gh', '<cmd>lua require("telescope.builtin").help_tags()<cr>', opts)
map('n', '<leader>gs', '<cmd>lua require("telescope.builtin").lsp_document_symbols()<cr>', opts)
map('n', '<leader>gr', '<cmd>lua require("telescope.builtin").lsp_references()<cr>', opts)

-- Neogit keymaps
map('n', '<leader>gg', '<cmd>Neogit<cr>', opts)

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
map('n', '<Space>f', function()
  require("conform").format({
    lsp_fallback = true,
    timeout_ms = 3000,
  })
end, opts)

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
map('t', '<C-\\>', '<cmd>ToggleTermToggleAll<cr>', opts)
map('t', 'lj', '<C-\\><C-n>', opts)  -- Quick exit to normal mode
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
