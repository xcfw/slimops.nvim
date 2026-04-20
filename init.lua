-- init.lua
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Basic options
vim.g.mapleader = ";"
vim.g.maplocalleader = ";"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.termguicolors = true -- Essential for theme support

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.g.python3_host_prog = vim.fn.expand("~/.nvim-venv/bin/python")

-- text width
vim.opt.textwidth = 100
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.colorcolumn = "100"
vim.opt.formatoptions = "tcqjnl" -- t=autowrap text, c=autowrap comments, q=allow gq formatting, j=remove comment leader when joining, n=recognize numbered lists, l=don't break long lines in insert mode

-- to reduce startup time
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- Built-in auto-reload when files change on disk (replaces hotreload plugin)
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	callback = function()
		if vim.fn.mode() ~= "c" then
			vim.cmd("checktime")
		end
	end,
})

-- Indentation settings
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Persistent undo
vim.opt.undofile = true
vim.opt.undolevels = 999

-- Always show sign column for diagnostics + gitsigns
vim.opt.signcolumn = "yes"

-- Diagnostic display (Neovim 0.10+ API)
vim.o.cmdheight = 0
vim.diagnostic.config({
	underline = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "",
		},
		-- Highlight line numbers for lines with diagnostics
		numhl = {
			[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
			[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
		},
	},
})

-- Wavy underlines for diagnostics (requires terminal with undercurl support)
-- + Neogit diff highlights (nvim-solarized-lua doesn't define them)
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = "#f38ba8" })
		vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = "#f9e2af" })
		vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = "#89dceb" })
		vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = "#a6e3a1" })

		-- Neogit diff: link to native Diff* groups so solarized theme controls colors
		local neogit_links = {
			{ "NeogitDiffAdd", "DiffAdd" },
			{ "NeogitDiffDelete", "DiffDelete" },
			{ "NeogitDiffAddHighlight", "DiffAdd" },
			{ "NeogitDiffDeleteHighlight", "DiffDelete" },
			{ "NeogitDiffContext", "Normal" },
			{ "NeogitDiffContextHighlight", "CursorLine" },
			{ "NeogitHunkHeader", "Title" },
			{ "NeogitHunkHeaderHighlight", "Title" },
		}
		for _, pair in ipairs(neogit_links) do
			vim.api.nvim_set_hl(0, pair[1], { link = pair[2], force = true })
		end
	end,
})

-- Flash yanked region briefly
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Helm and Go template filetype detection
vim.filetype.add({
	extension = {
		gotmpl = "helm",
		tpl = "helm",
	},
	pattern = {
		[".*/templates/.*%.tpl"] = "helm",
		[".*/templates/.*%.ya?ml"] = "helm",
		["helmfile.*%.ya?ml"] = "helm",
	},
})

-- Load centralized keymaps BEFORE plugins
require("config.keymaps")

local function apply_solarized_background(bg)
	vim.o.background = bg
	pcall(vim.cmd, "colorscheme solarized")
end

-- Set up plugins
require("lazy").setup({
	-- Solarized theme (original Ethan Schoonover palette)
	{
		"ishan9299/nvim-solarized-lua",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd("colorscheme solarized")
		end,
	},

	-- Auto dark/light mode following macOS appearance
	{
		"f-person/auto-dark-mode.nvim",
		priority = 999,
		opts = {
			set_dark_mode = function()
				apply_solarized_background("dark")
			end,
			set_light_mode = function()
				apply_solarized_background("light")
			end,
		},
	},

	-- Git signs in the gutter
	{
		"lewis6991/gitsigns.nvim",
		lazy = false,
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "+" },
					change = { text = "~" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
				current_line_blame = true,
				current_line_blame_opts = {
					virt_text = true,
					virt_text_pos = "eol",
					delay = 500,
				},
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns
					local map = function(mode, l, r, desc)
						vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
					end

					-- Navigation between hunks
					map("n", "]h", gs.next_hunk, "Next hunk")
					map("n", "[h", gs.prev_hunk, "Prev hunk")

					-- Preview hunk
					map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
				end,
			})
		end,
	},

	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				-- Only configure non-default values
				shading_factor = 2,
				open_mapping = [[<c-\>]],
				size = math.floor(vim.o.lines * 0.7),
			})
		end,
	},

	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},

  -- whichkey hints for keymaps
  {
    "folke/which-key.nvim",
      event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
  },
	-- Syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		lazy = false,
		config = function()
			local ensure = {
				"dockerfile",
				"lua",
				"vim",
				"vimdoc",
				"javascript",
				"typescript",
				"python",
				"go",
				"ruby",
				"html",
				"css",
				"json",
				"yaml",
				"terraform",
				"hcl",
				"markdown",
				"markdown_inline",
				"gotmpl",
				"helm",
			}
			require("nvim-treesitter").install(ensure)

			-- filetype -> parser name overrides
			local ft_to_lang = {
				gotmpl = "gotmpl",
				helm = "helm",
				terraform = "terraform",
				tf = "terraform",
			}

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(ev)
					local ft = vim.bo[ev.buf].filetype
					local lang = ft_to_lang[ft] or vim.treesitter.language.get_lang(ft) or ft
					if not lang or lang == "" then
						return
					end
					local ok = pcall(vim.treesitter.start, ev.buf, lang)
					if ok then
						vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},

	-- Status line
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"echasnovski/mini.icons",
		},
		config = function()
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "auto", -- keep it automatic, don't change
				},
				sections = {
					lualine_b = { "diagnostics" },
					lualine_c = {
						{
							"filename",
							path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
						},
					},
					lualine_x = { "encoding", "fileformat", "filetype" },
				},
			})
		end,
	},
	-- Tab bar
	{
		"romgrk/barbar.nvim",
		dependencies = { "echasnovski/mini.icons" },
		config = function()
			require("barbar").setup({
				animation = false,
				auto_hide = false,
				clickable = true,
				exclude_ft = { "NvimTree" },
				exclude_name = {},
				icons = {
					button = "",
					filetype = {
						enabled = true,
					},
				},
			})
		end,
	},

	-- LSP Configuration (intentionally without Mason to keep it minimal and simple)
	-- Using native Neovim 0.11+ vim.lsp.config API
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Set capabilities for all LSP servers globally
			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			-- Lua LSP (install: brew install lua-language-server on macOS)
			vim.lsp.config.lua_ls = {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						format = { enable = true },
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
						},
					},
				},
			}

			-- Helm LSP (install: brew install helm-ls)
			vim.lsp.config.helm_ls = {
				filetypes = { "helm" },
				settings = {
					["helm-ls"] = {
						yamlls = {
							path = "yaml-language-server",
							enabled = false,
						},
					},
				},
			}

			-- YAML LSP (install: npm install -g yaml-language-server)
			vim.lsp.config.yamlls = {
				filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
				settings = {
					yaml = {
						schemas = {
							["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
							["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "/*.k8s.yaml",
							["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/docker-compose*.{yml,yaml}",
						},
						format = { enable = true },
						validate = true,
						completion = true,
					},
				},
				on_attach = function(client, bufnr)
					local filetype = vim.bo[bufnr].filetype
					if filetype == "helm" then
						vim.lsp.stop_client(client.id)
					end
				end,
			}

			-- Enable all LSP servers
			-- Install instructions:
			-- pyright: pip install pyright
			-- gopls: go install golang.org/x/tools/gopls@latest
			-- solargraph: gem install solargraph
			-- lua_ls: brew install lua-language-server
			-- html/cssls/jsonls: npm install -g vscode-langservers-extracted
			-- ts_ls: npm install -g typescript typescript-language-server
			-- dockerls: npm install -g dockerfile-language-server-nodejs
			-- helm_ls: brew install helm-ls
			-- tailwindcss: npm install -g @tailwindcss/language-server
			-- yamlls: npm install -g yaml-language-server
			-- terraformls: brew install terraform-ls
			vim.lsp.enable({
				"pyright",
				"gopls",
				"solargraph",
				"lua_ls",
				"html",
				"cssls",
				"jsonls",
				"ts_ls",
				"dockerls",
				"helm_ls",
				"tailwindcss",
				"yamlls",
				"terraformls",
			})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"zbirenbaum/copilot.lua",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
				mapping = cmp.mapping.preset.insert({
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = false,
					}),
					["<Tab>"] = cmp.mapping(function(fallback)
						local copilot = require("copilot.suggestion")
						if copilot.is_visible() then
							copilot.accept()
						elseif cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				experimental = {
					ghost_text = false,
				},
			})
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				copilot_model = "gpt-41-copilot",
				suggestion = {
					enabled = true,
					auto_trigger = true,
					keymap = { accept = false },
				},
				panel = { enabled = false },
				workspace_folders = {
					vim.fn.expand("~/dev/"),
					vim.fn.expand("~/tools/"),
					vim.fn.expand("~/.config/"),
					vim.fn.expand("~/.zsh*"),
				},
				filetypes = {
					gitcommit = true,
					markdown = true,
					yaml = true,
				},
			})
		end,
	},

	-- Git integration
	{
		"NeogitOrg/neogit",
		dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
		config = function()
			require("neogit").setup({
				integrations = { diffview = true },
			})

			-- Workaround: nvim 0.12 errors E474 when neogit reuses the
			-- NeogitConsole buffer and tries to reset buftype from 'terminal'
			-- to 'nofile'. Wipe any stale terminal buffer first.
			local Buffer = require("neogit.lib.buffer")
			local orig_from_name = Buffer.from_name
			Buffer.from_name = function(name)
				local h = vim.fn.bufnr(name)
				if h ~= -1 and vim.bo[h].buftype == "terminal" then
					pcall(vim.api.nvim_buf_delete, h, { force = true })
				end
				return orig_from_name(name)
			end
		end,
	},

	-- Diff viewer for merge conflicts (3-way merge)
	{
		"sindrets/diffview.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local actions = require("diffview.actions")
			require("diffview").setup({
				view = {
					merge_tool = {
						layout = "diff3_horizontal", -- LOCAL | BASE | REMOTE (3 panes, synced scroll)
						disable_diagnostics = true,
						winbar_info = true,
					},
				},
				hooks = {
					view_opened = function()
						-- Focus the middle pane (BASE) when merge view opens
						vim.defer_fn(function()
							vim.cmd("wincmd l") -- Move to middle pane
						end, 50)
					end,
				},
				keymaps = {
					view = {
						-- Conflict resolution (using actions API)
						{ "n", "<space>co", actions.conflict_choose("ours"), { desc = "Choose OURS" } },
						{ "n", "<space>ct", actions.conflict_choose("theirs"), { desc = "Choose THEIRS" } },
						{ "n", "<space>cb", actions.conflict_choose("base"), { desc = "Choose BASE" } },
						{ "n", "<space>ca", actions.conflict_choose("all"), { desc = "Choose ALL" } },
						{ "n", "<space>cx", actions.conflict_choose("none"), { desc = "Delete conflict" } },
						-- Close with ;q
						{ "n", "<leader>q", "<cmd>DiffviewClose<CR>", { desc = "Close diffview" } },
					},
					file_panel = {
						-- Tab to cycle through conflicted files
						{ "n", "<Tab>", actions.select_next_entry, { desc = "Next file" } },
						{ "n", "<S-Tab>", actions.select_prev_entry, { desc = "Prev file" } },
						-- Close with ;q
						{ "n", "<leader>q", "<cmd>DiffviewClose<CR>", { desc = "Close diffview" } },
					},
				},
			})
		end,
	},

	-- GitHub link integration - open files in browser
	{
		"linrongbin16/gitlinker.nvim",
		config = function()
			local gitlinker = require("gitlinker")
			gitlinker.setup()
			-- Set up custom keymaps that open in browser
			vim.keymap.set({ "n", "v" }, "<leader>gu", function()
				gitlinker.link({ action = vim.ui.open })
			end, { desc = "Open GitHub URL in browser" })
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-live-grep-args.nvim",
				version = "^1.0.0",
			},
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup()
			telescope.load_extension("live_grep_args")
		end,
	},

	-- Comment toggling
	{
		"numToStr/Comment.nvim",
		lazy = false,
		config = function()
			require("Comment").setup()
		end,
	},

	-- Mini file-manager

	{
		"echasnovski/mini.files",
		version = "*",
		dependencies = { "echasnovski/mini.icons" },
		config = function()
			require("mini.files").setup({
				mappings = { synchronize = "`", close = ";;", go_in_plus = "l", go_in = "L" },
			})
		end,
	},

	-- Surround operations using mini.nvim
	{
		"echasnovski/mini.surround",
		version = "*",
		config = function()
			require("mini.surround").setup()
		end,
	},

	-- Auto-pairing brackets, quotes, etc.
	{
		"echasnovski/mini.pairs",
		version = "*",
		config = function()
			require("mini.pairs").setup({
				mappings = {
					["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^`\\].", register = { cr = false } },
				},
			})
		end,
	},

	-- Smooth movement animations
	{
		"echasnovski/mini.animate",
		version = "*",
		config = function()
			local animate = require("mini.animate")
			animate.setup({
				scroll = { enable = false },
			})
		end,
	},

	-- Smart text alignment
	{
		"echasnovski/mini.align",
		version = "*",
		config = function()
			require("mini.align").setup()
		end,
	},

	-- Move lines/selections with arrow keys (keymaps in keymaps.lua)
	{
		"echasnovski/mini.move",
		version = "*",
		config = function()
			require("mini.move").setup({
				mappings = {
					left = "",
					right = "",
					down = "",
					up = "",
					line_left = "",
					line_right = "",
					line_down = "",
					line_up = "",
				},
			})
		end,
	},

	-- Remember cursor position in files
	{
		"ethanholz/nvim-lastplace",
		config = function()
			require("nvim-lastplace").setup({
				lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
				lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
				lastplace_open_folds = true,
			})
		end,
	},

	-- Indent guides
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		config = function()
			require("ibl").setup({
				indent = {
					char = "│",
					tab_char = "│",
				},
				scope = {
					enabled = true,
					show_start = true,
					show_end = false,
				},
				exclude = {
					filetypes = {
						"help",
						"alpha",
						"dashboard",
						"nvim-tree",
						"Trouble",
						"trouble",
						"lazy",
						"mason",
						"notify",
						"toggleterm",
						"lazyterm",
					},
				},
			})
		end,
	},

	-- Additional plugins
	{
		"echasnovski/mini.icons",
		version = "*",
		lazy = false,
		config = function()
			require("mini.icons").setup()
			MiniIcons.mock_nvim_web_devicons()
		end,
	},
	{ "nvim-lua/plenary.nvim" },

	-- Seamless navigation between nvim splits and tmux panes
	{
		"christoomey/vim-tmux-navigator",
		lazy = false,
	},

	-- Claude terminal integration
	{
		dir = "~/.config/nvim/lua/claude-prompt",
		name = "claude-prompt",
		dependencies = { "akinsho/toggleterm.nvim" },
	},

	-- Telescope terminal picker
	{
		"tknightz/telescope-termfinder.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "akinsho/toggleterm.nvim" },
		config = function()
			require("telescope").load_extension("termfinder")
		end,
	},

	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"echasnovski/mini.icons",
		},
		opts = {},
	},

	-- Code formatting
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "isort", "black" },
					javascript = { "prettier" },
					typescript = { "prettier" },
					json = { "prettier" },
					html = { "prettier" },
					css = { "prettier" },
					markdown = { "prettier" },
					yaml = { "yamlfmt" },
					terraform = { "terraform_fmt" },
					tf = { "terraform_fmt" },
					hcl = { "terragrunt_hclfmt" },
					sh = { "shfmt" },
					bash = { "shfmt" },
					zsh = { "beautysh" },
					-- helm: no formatter - yamlfmt breaks {{ .Values }} templates
				},
				formatters = {
					terragrunt_hclfmt = {
						command = "terragrunt",
						args = { "hcl", "fmt", "--file", "$FILENAME" },
						stdin = false,
					},
				},
				format_on_save = nil, -- Disabled by default, use manual formatting with <space>f
				format_after_save = nil,
			})
		end,
	},
})

-- clipboard copy nvim messages
vim.api.nvim_create_user_command("Mc", function()
	vim.fn.system("pbcopy", vim.fn.execute("messages"))
end, {})

local bufferline_api = require("bufferline.api")
