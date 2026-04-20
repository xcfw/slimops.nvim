-- lua/config/keymaps.lua
-- Centralized keymaps for all plugins and Neovim functions

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Wrapped line navigation (respects count: 5j still jumps 5 real lines)
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, noremap = true, silent = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, noremap = true, silent = true })

-- Y yanks to end of line (consistent with D, C)
map("n", "Y", "y$", opts)

-- Toggle virtual diagnostics + inlay hints
map("n", "<BS>", function()
	local cfg = vim.diagnostic.config()
	vim.diagnostic.config({ virtual_text = not cfg.virtual_text })
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { noremap = true, silent = true, desc = "Toggle diagnostics/inlay hints" })

-- General keymaps
map("n", "<leader>w", function() vim.cmd("up") end, opts)
map("n", "<leader>q", function() vim.cmd("BufferClose") end, opts)
map("n", "<leader><leader>", "ZQ", opts)
map("n", "<Esc>", function() vim.cmd("nohl") end, opts)

-- Page navigation (works in both buffers and terminal)
local page_nav_modes = { "n", "t" }
map(page_nav_modes, "<M-j>", "<C-f>", opts) -- Page down
map(page_nav_modes, "<M-k>", "<C-b>", opts) -- Page up

-- Precise scroll: PageDown/PageUp scroll viewport by N lines
local page_scroll = 3
local function scroll(key)
	return function()
		local keys = vim.api.nvim_replace_termcodes(page_scroll .. key, true, false, true)
		vim.api.nvim_feedkeys(keys, "n", false)
	end
end
for _, m in ipairs({ "n", "v", "i" }) do
	map(m, "<PageDown>", scroll("<C-e>"), opts)
	map(m, "<PageUp>", scroll("<C-y>"), opts)
end

-- Copy file paths to system clipboard
map("n", "<Space>y", function() vim.fn.setreg("+", vim.fn.expand("%")) end, opts)
map("n", "<Space>Y", function() vim.fn.setreg("+", vim.fn.expand("%:p")) end, opts)
map("n", "<Space>u", function() vim.fn.setreg("+", vim.fn.expand("%:t")) end, opts)

-- Clipboard behavior: specific deletions go to 'd' register (local only, not system clipboard)
map("n", "dd", '"ddd', opts) -- Delete line to 'd' register
map("n", "D", '"dD', opts) -- Delete to end of line to 'd' register
map("n", "de", '"dde', opts) -- Delete to end of word to 'd' register
map("n", "d$", '"dd$', opts) -- Delete to end of line to 'd' register
map("n", "C", '"dC', opts) -- Change to end of line to 'd' register

-- paste from d register without overwriting it
map("x", "<Space>p", '"dp', opts)
map("n", "<Space>P", '"dP', opts)

-- nvim-tree keymaps
map("n", "<leader>e", function()
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" or vim.fn.filereadable(file) == 0 then
		require("mini.files").open(nil, false)
	else
		require("mini.files").open(file, false)
	end
end, opts)

-- Barbar keymaps (tabs/buffers)
map("n", "<Tab>", "<C-^>", opts)
map("n", "<S-Tab>", function() vim.cmd("BufferNext") end, opts)
for i = 1, 4 do
	map("n", "<M-" .. i .. ">", function() vim.cmd("BufferGoto " .. i) end, opts)
end

-- Telescope keymaps
map("n", "<leader>l", function()
	require("telescope.builtin").oldfiles({ cwd_only = true })
end, opts)

map("n", "<leader>k", function()
	require("telescope").extensions.live_grep_args.live_grep_args()
end, opts)

map("n", "<leader>K", function()
	require("telescope").extensions.live_grep_args({
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--hidden",
			"--no-ignore",
			"--unrestricted",
		},
	})
end, opts)

map("n", "<leader>f", function()
	require("telescope.builtin").live_grep({ additional_args = { "--hidden", "--no-ignore" } })
end, opts)

map("n", "<leader>J", function()
	require("telescope.builtin").find_files({
		find_command = {
			"rg",
			"--files",
			"--hidden",
			"--no-ignore",
			"--glob", "!**/.git/*",
			"--glob", "!**/node_modules/*",
			"--glob", "!**/target/*",
			"--glob", "!**/build/*",
			"--glob", "!**/dist/*",
			"--glob", "!**/.cache/*",
			"--glob", "!**/.local/share/*",
			"--glob", "!**/.npm/*",
		},
	})
end, opts)

map("n", "<leader>gh", function() require("telescope.builtin").help_tags() end, opts)
map("n", "<leader>gs", function() require("telescope.builtin").lsp_document_symbols() end, opts)
map("n", "<leader>gr", function() require("telescope.builtin").lsp_references() end, opts)

-- Neogit keymaps
map("n", "<leader>gg", function() vim.cmd("Neogit") end, opts)

-- LSP keymaps
map("n", "gd", function() vim.lsp.buf.definition() end, opts)
map("n", "gD", function() vim.lsp.buf.declaration() end, opts)
map("n", "gi", function() vim.lsp.buf.implementation() end, opts)
map("n", "gr", function() vim.lsp.buf.references() end, opts)
map("n", "K", function() vim.lsp.buf.hover() end, opts)

-- Code actions and refactoring
map("n", "<Space>ca", function() vim.lsp.buf.code_action() end, opts)
map("n", "<Space>rn", function() vim.lsp.buf.rename() end, opts)
map("n", "<Space>f", function()
	require("conform").format({
		lsp_fallback = true,
		timeout_ms = 3000,
	})
end, opts)

-- Diagnostics
map("n", "<Space>d", function() vim.diagnostic.open_float() end, opts)
map("n", "<Space>dl", function() vim.diagnostic.setloclist() end, opts)
map("n", "<Space>dq", function() vim.diagnostic.setqflist() end, opts)

-- Navigation (keep bracket style for consistency)
map("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
map("n", "]d", function() vim.diagnostic.goto_next() end, opts)

-- Workspace operations
map("n", "<Space>wa", function() vim.lsp.buf.add_workspace_folder() end, opts)
map("n", "<Space>wr", function() vim.lsp.buf.remove_workspace_folder() end, opts)
map("n", "<Space>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)

-- Copilot integration (native suggestion, no copilot-cmp)
-- Tab accepts Copilot ghost-text
-- Enter accepts explicit cmp completions, otherwise newline
-- S-Tab navigates cmp menu

-- Window/tmux navigation in terminal mode (vim-tmux-navigator handles normal mode)
map("t", "<C-h>", function() vim.cmd("TmuxNavigateLeft") end, opts)
map("t", "<C-j>", function() vim.cmd("TmuxNavigateDown") end, opts)
map("t", "<C-k>", function() vim.cmd("TmuxNavigateUp") end, opts)
map("t", "<C-l>", function() vim.cmd("TmuxNavigateRight") end, opts)

-- Terminal configurations using toggleterm
-- Floating terminal (;s)
local cached_floating_terminal = nil
local function get_floating_terminal()
	if not cached_floating_terminal then
		local Terminal = require("toggleterm.terminal").Terminal
		cached_floating_terminal = Terminal:new({
			direction = "float",
			float_opts = {
				border = "curved",
				winblend = 0,
				highlights = {
					border = "Normal",
					background = "Normal",
				},
				width = math.floor(vim.o.columns * 0.8),
				height = math.floor(vim.o.lines * 0.8),
			},
		})
	end
	return cached_floating_terminal
end

-- Terminal keymaps
map("t", ";l", "<C-\\><C-n>", opts) -- Quick exit to normal mode
map("n", "<leader>s", function()
	get_floating_terminal():toggle()
end, opts)

-- pi agent in tmux popup (nvim context auto-injected via ~/.pi/agent/extensions/nvim-context.ts)
_G.pi_context = function()
	local bufs = {}
	for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
		if b.name and b.name ~= "" then
			table.insert(bufs, {
				path = b.name,
				modified = b.changed == 1,
				current = b.bufnr == vim.api.nvim_get_current_buf(),
			})
		end
	end

	local cur_path = vim.api.nvim_buf_get_name(0)
	local cur = nil
	if cur_path ~= "" then
		local pos = vim.api.nvim_win_get_cursor(0)
		cur = { path = cur_path, line = pos[1], col = pos[2] + 1, ft = vim.bo.filetype }
	end

	local sel = nil
	local sp, ep = vim.fn.getpos("'<"), vim.fn.getpos("'>")
	if sp[2] > 0 and ep[2] > 0 and (sp[2] < ep[2] or (sp[2] == ep[2] and sp[3] <= ep[3])) then
		local ok, lines = pcall(vim.api.nvim_buf_get_lines, 0, sp[2] - 1, ep[2], false)
		if ok and lines and #lines > 0 then
			sel = {
				start = { sp[2], sp[3] },
				["end"] = { ep[2], ep[3] },
				text = table.concat(lines, "\n"),
			}
		end
	end

	local diags = {}
	for _, d in ipairs(vim.diagnostic.get(0)) do
		table.insert(diags, {
			path = cur_path,
			line = d.lnum + 1,
			sev = d.severity,
			msg = d.message,
		})
	end

	return vim.json.encode({
		cwd = vim.fn.getcwd(),
		cur = cur,
		buffers = bufs,
		selection = sel,
		diagnostics = diags,
	})
end

map("n", "<leader>p", function()
	if vim.env.TMUX == nil then
		vim.notify("pi: not inside tmux", vim.log.levels.WARN)
		return
	end

	local pi_bin = vim.fn.exepath("pi")
	if pi_bin == "" then
		vim.notify("pi: binary not found", vim.log.levels.ERROR)
		return
	end

	local sock = vim.v.servername
	local cwd = vim.fn.getcwd()
	local job = vim.fn.jobstart({
		"tmux",
		"display-popup",
		"-d", cwd,
		"-w", "80%",
		"-h", "80%",
		"-E",
		string.format("NVIM=%s %s", vim.fn.shellescape(sock), vim.fn.shellescape(pi_bin)),
	}, { detach = true })

	if job <= 0 then
		vim.notify("pi: failed to spawn tmux popup", vim.log.levels.ERROR)
	end
end, { noremap = true, silent = true, desc = "pi agent (tmux popup)" })

-- Claude terminals (copy path/selection to clipboard, then open terminal)
map("n", "<leader>a", function()
	require("claude-prompt").open_default()
end, opts)
map("v", "<leader>a", function()
	require("claude-prompt").open_default_visual()
end, opts)
map("n", "<leader>d", function()
	require("claude-prompt").open_work()
end, opts)
map("v", "<leader>d", function()
	require("claude-prompt").open_work_visual()
end, opts)
map("n", "<leader>r", function()
	require("claude-prompt").open_code()
end, opts)

-- Terminal picker (compact dialog, normal mode for hjkl navigation)
map("n", "<M-\\>", function()
	require("telescope").extensions.termfinder.find({
		initial_mode = "normal",
		layout_strategy = "vertical",
		layout_config = {
			width = 0.4,
			height = 0.4,
			prompt_position = "top",
		},
	})
end, opts)

-- Gitsigns keymaps
map("n", "]c", function() vim.cmd("Gitsigns next_hunk") end, opts)
map("n", "[c", function() vim.cmd("Gitsigns prev_hunk") end, opts)

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

-- mini.move: move line/selection with arrow keys
map("n", "<Down>", function() require("mini.move").move_line("down") end, opts)
map("n", "<Up>", function() require("mini.move").move_line("up") end, opts)
map("n", "<Left>", function() require("mini.move").move_line("left") end, opts)
map("n", "<Right>", function() require("mini.move").move_line("right") end, opts)
map("v", "<Down>", function() require("mini.move").move_selection("down") end, opts)
map("v", "<Up>", function() require("mini.move").move_selection("up") end, opts)
map("v", "<Left>", function() require("mini.move").move_selection("left") end, opts)
map("v", "<Right>", function() require("mini.move").move_selection("right") end, opts)

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

map("v", "<leader>b", function() base64_encode() end, { noremap = true, silent = true, desc = "Base64 encode" })
map("v", "<leader>B", function() base64_decode() end, { noremap = true, silent = true, desc = "Base64 decode" })

-- Export functions for visual mode keymaps
return {
	base64_encode = base64_encode,
	base64_decode = base64_decode,
}
