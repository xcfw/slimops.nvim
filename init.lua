-- init.lua
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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
vim.opt.termguicolors = true  -- Essential for theme support
vim.opt.clipboard = "unnamedplus"  -- Use system clipboard for yank operations

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

-- Set up diagnostic signs early to avoid nvim-tree errors
vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })

-- Define nvim-tree specific diagnostic signs
vim.fn.sign_define("NvimTreeDiagnosticErrorIcon", { text = "", texthl = "NvimTreeDiagnosticErrorIcon" })
vim.fn.sign_define("NvimTreeDiagnosticWarnIcon", { text = "", texthl = "NvimTreeDiagnosticWarnIcon" })
vim.fn.sign_define("NvimTreeDiagnosticInfoIcon", { text = "", texthl = "NvimTreeDiagnosticInfoIcon" })
vim.fn.sign_define("NvimTreeDiagnosticHintIcon", { text = "", texthl = "NvimTreeDiagnosticHintIcon" })


-- Load centralized keymaps BEFORE plugins
require("config.keymaps")

-- Set up plugins
require("lazy").setup({
  -- Add Catppuccin back in the first position
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
  },

  -- Modern file explorer
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFindFile" },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        renderer = {
          group_empty = true,
          highlight_git = true,
        },
        git = {
          ignore = false,
        },
        diagnostics = {
          enable = true,
          show_on_dirs = true,
          debounce_delay = 50,
          icons = {
            hint = "",
            info = "",
            warning = "",
            error = "",
          },
        },
        actions = {
          open_file = {
            window_picker = {
              enable = false,
            },
          },
          remove_file = {
            close_window = true,
          },
        },
        update_focused_file = {
          enable = true,
        },
      })
    end,
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
        size = math.floor(vim.o.lines * 0.7)
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
  
  -- Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { 
          "dockerfile", "lua", "vim", "vimdoc", "javascript", "typescript", 
          "python", "go", "ruby", "html", "css", "json", "yaml", "terraform", 
          "hcl", "markdown", "markdown_inline" 
        },
        highlight = { enable = true },
        autotag = { enable = true },
        context_commentstring = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = ";v",
            node_incremental = "<CR>",
            node_decremental = "<BS>",
          },
        },
      })
    end,
  },
  
  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { 
      "nvim-tree/nvim-web-devicons",
      "catppuccin/nvim", -- Add explicit dependency
    },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "auto", -- Change from catppuccin to auto
        },
        sections = {
          lualine_c = {
            {
              'filename',
              path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
            }
          }
        }
      })
    end,
  },
  -- Tab bar
  {
    "romgrk/barbar.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  
  -- LSP Configuration (intentionally without Mason to keep it minimal and simple)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Configure individual LSP servers
      -- You'll need to install these manually via your system package manager
      -- or use language-specific package managers

      -- Python LSP (install: pip install pyright)
      lspconfig.pyright.setup({
        capabilities = capabilities,
      })

      -- Go LSP (install: go install golang.org/x/tools/gopls@latest)
      lspconfig.gopls.setup({
        capabilities = capabilities,
      })

      -- Ruby LSP (install: gem install solargraph)
      lspconfig.solargraph.setup({
        capabilities = capabilities,
      })

      -- Lua LSP (install: brew install lua-language-server on macOS)
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
	    format = { enable = true },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
            },
          },
        },
      })

      -- HTML LSP (install: npm install -g vscode-langservers-extracted)
      lspconfig.html.setup({
        capabilities = capabilities,
      })

      -- CSS LSP (install: npm install -g vscode-langservers-extracted)
      lspconfig.cssls.setup({
        capabilities = capabilities,
      })

      -- JSON LSP (install: npm install -g vscode-langservers-extracted)
      lspconfig.jsonls.setup({
        capabilities = capabilities,
      })

      -- TypeScript/JavaScript LSP (install: npm install -g typescript typescript-language-server)
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
      })

      lspconfig.dockerls.setup({
        capabilities = capabilities,
      })

      lspconfig.helm_ls.setup {
        capabilities = capabilities,
        settings = {
          ['helm-ls'] = {
            yamlls = {
              path = "yaml-language-server",
            }
          }
        }
      }      

      -- Tailwind CSS LSP (install: npm install -g @tailwindcss/language-server)
      lspconfig.tailwindcss.setup({
        capabilities = capabilities,
      })

      -- YAML LSP (install: npm install -g yaml-language-server)
      lspconfig.yamlls.setup({
        capabilities = capabilities,
        settings = {
          yaml = {
            schemas = {
              ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
              ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "/*.k8s.yaml",
              ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/docker-compose*.yml",
              ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/docker-compose*.yaml",
            },
            format = { enable = true },
            validate = true,
            completion = true,
          },
        },
      })

      -- Terraform LSP (install: brew install terraform-ls on macOS, or download from HashiCorp)
      lspconfig.terraformls.setup({
        capabilities = capabilities,
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
      "zbirenbaum/copilot-cmp",
    },
    config = function()
      local cmp = require("cmp")
      require("copilot_cmp").setup()
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "copilot" },
          { name = "buffer" },
          { name = "path" },
        }),
        mapping = cmp.mapping.preset.insert({
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
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
      })
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
	copilot_node_command = "node",
        filetypes = {
          gitcommit = true,  -- Enable Copilot for git commit messages
          markdown = true,
          yaml = true,
        },
      })
    end,
  },

  -- Git integration
  {
    "TimUntersberger/neogit",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("neogit").setup()
    end,
  },
  
  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup()
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

  -- Surround operations using mini.nvim
  {
    "echasnovski/mini.surround",
    version = "*",
    config = function()
      require("mini.surround").setup()
    end,
  },

  -- Smooth movement animations
  {
    "echasnovski/mini.animate",
    version = "*",
    config = function()
      require("mini.animate").setup()
    end,
  },

  -- Remember cursor position in files
  {
    "ethanholz/nvim-lastplace",
    config = function()
      require("nvim-lastplace").setup({
        lastplace_ignore_buftype = {"quickfix", "nofile", "help"},
        lastplace_ignore_filetype = {"gitcommit", "gitrebase", "svn", "hgcommit"},
        lastplace_open_folds = true
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
            "neo-tree",
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
    "nvim-tree/nvim-web-devicons",
    lazy = false,  -- Force immediate loading
  },
  { "nvim-lua/plenary.nvim" },
})

-- Apply colorscheme after plugins are loaded
vim.cmd("colorscheme catppuccin")

-- Add compatibility between nvim-tree and barbar
local nvim_tree_events = require('nvim-tree.events')
local bufferline_api = require('bufferline.api')

local function get_tree_size()
  return require'nvim-tree.view'.View.width
end

nvim_tree_events.subscribe('TreeOpen', function()
  bufferline_api.set_offset(get_tree_size())
end)

nvim_tree_events.subscribe('Resize', function()
  bufferline_api.set_offset(get_tree_size())
end)

nvim_tree_events.subscribe('TreeClose', function()
  bufferline_api.set_offset(0)
end)

