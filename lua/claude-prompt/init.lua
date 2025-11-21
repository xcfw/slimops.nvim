-- lua/claude-prompt/init.lua
-- Minimal Claude terminal integration

local M = {}

local function toggle_terminal(id, cmd)
  require('toggleterm.terminal').Terminal:new({
    id = id,
    cmd = cmd,
    direction = 'horizontal',
    size = function() return math.floor(vim.o.lines * 0.7) end,
  }):toggle()
end

local function copy_path_and_open(id, cmd)
  local path = vim.fn.expand('%:.')
  if path ~= '' then
    vim.fn.setreg('+', path)
  end
  toggle_terminal(id, cmd)
end

local function copy_selection_and_open(id, cmd)
  -- Yank selection to system clipboard
  vim.cmd('noautocmd normal! "+y')
  toggle_terminal(id, cmd)
end

-- Normal mode: copy file path
function M.open_default()
  copy_path_and_open(10, 'claude')
end

function M.open_work()
  copy_path_and_open(11, 'claude --profile work')
end

-- Visual mode: copy selection
function M.open_default_visual()
  copy_selection_and_open(10, 'claude')
end

function M.open_work_visual()
  copy_selection_and_open(11, 'claude --profile work')
end

return M
