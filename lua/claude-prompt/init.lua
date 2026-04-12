-- lua/claude-prompt/init.lua
-- Minimal Claude/Opencode terminal integration

local M = {}

-- Switch between 'claude' and 'opencode'
M.backend = 'claude'

-- Cache terminal instances for proper toggling
local terminals = {}

local backends = {
  claude = {
    default = { id = 10, cmd = 'claude' },
    work    = { id = 11, cmd = 'ANTHROPIC_API_KEY="" CLAUDE_CONFIG_DIR=~/.claude-work claude' },
    code    = { id = 12, cmd = 'opencode' },
  },
}

local function toggle_terminal(id, cmd)
  if not terminals[id] then
    terminals[id] = require('toggleterm.terminal').Terminal:new({
      id = id,
      cmd = cmd,
      direction = 'horizontal',
      size = function() return math.floor(vim.o.lines * 0.7) end,
    })
  end
  terminals[id]:toggle()
end

local function copy_path_and_open(id, cmd)
  local path = vim.fn.expand('%:.')
  if path ~= '' then
    vim.fn.setreg('+', path)
  end
  toggle_terminal(id, cmd)
end

local function copy_selection_and_open(id, cmd)
  vim.cmd('noautocmd normal! "+y')
  toggle_terminal(id, cmd)
end

local aliases = { c = 'claude', o = 'opencode', claude = 'claude' }

function M.set_backend(val)
  local resolved = aliases[val]
  if not resolved then
    vim.notify('AI: unknown backend "' .. val .. '" (use c/claude or o/opencode)', vim.log.levels.ERROR)
    return
  end
  M.backend = resolved
  vim.notify('AI backend: ' .. M.backend, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('AI', function(args)
  M.set_backend(args.args)
end, {
  nargs = 1,
  complete = function() return { 'c', 'o', 'claude', 'opencode' } end,
  desc = 'Set AI backend (c/claude or o/opencode)',
})

-- Normal mode: copy file path
function M.open_default()
  local b = backends[M.backend].default
  copy_path_and_open(b.id, b.cmd)
end

function M.open_work()
  local b = backends[M.backend].work
  copy_path_and_open(b.id, b.cmd)
end

-- Visual mode: copy selection
function M.open_default_visual()
  local b = backends[M.backend].default
  copy_selection_and_open(b.id, b.cmd)
end

function M.open_work_visual()
  local b = backends[M.backend].work
  copy_selection_and_open(b.id, b.cmd)
end

function M.open_code()
  local b = backends[M.backend].code
  copy_path_and_open(b.id, b.cmd)
end

return M
