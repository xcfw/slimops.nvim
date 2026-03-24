-- lua/claude-prompt/init.lua
-- Minimal Claude terminal integration

local M = {}

-- Terminal profiles: add new entries here to create new Claude terminals
local profiles = {
	default = { id = 10, cmd = "claude" },
	work = { id = 11, cmd = "CLAUDE_CONFIG_DIR=~/.claude-work claude" },
}

-- Cache terminal instances for proper toggling
local terminals = {}

local function toggle_terminal(id, cmd)
	if not terminals[id] then
		terminals[id] = require("toggleterm.terminal").Terminal:new({
			id = id,
			cmd = cmd,
			direction = "horizontal",
			size = function()
				return math.floor(vim.o.lines * 0.7)
			end,
		})
	end
	terminals[id]:toggle()
end

local function copy_path_and_open(id, cmd)
	local path = vim.fn.expand("%:.")
	if path ~= "" then
		vim.fn.setreg("+", path)
	end
	toggle_terminal(id, cmd)
end

local function copy_selection_and_open(id, cmd)
	-- Yank selection to system clipboard
	vim.cmd('noautocmd normal! "+y')
	toggle_terminal(id, cmd)
end

-- Generate open functions for each profile
for name, cfg in pairs(profiles) do
	M["open_" .. name] = function()
		copy_path_and_open(cfg.id, cfg.cmd)
	end
	M["open_" .. name .. "_visual"] = function()
		copy_selection_and_open(cfg.id, cfg.cmd)
	end
end

return M
