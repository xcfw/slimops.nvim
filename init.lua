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
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.g.python3_host_prog = '/Users/xcfw/.nvim-venv/bin/python'

-- text width
vim.opt.textwidth = 100
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.colorcolumn = "100"
vim.opt.formatoptions = "tcqjnl"  -- t=autowrap text, c=autowrap comments, q=allow gq formatting, j=remove comment leader when joining, n=recognize numbered lists, l=don't break long lines in insert mode

-- to reduce startup time
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

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

-- Define nvim-tree specific diagnostic signs with fallback highlight groups
vim.fn.sign_define("NvimTreeDiagnosticErrorIcon", { text = "", texthl = "DiagnosticSignError" })
vim.fn.sign_define("NvimTreeDiagnosticWarnIcon", { text = "", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("NvimTreeDiagnosticInfoIcon", { text = "", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("NvimTreeDiagnosticHintIcon", { text = "", texthl = "DiagnosticSignHint" })

-- Helm and Go template filetype detection
vim.filetype.add({
  extension = {
    gotmpl = 'helm',
    tpl = 'helm',
  },
  pattern = {
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.ya?ml"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
  },
})

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
          "hcl", "markdown", "markdown_inline", "gotmpl", "helm" 
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
    config = function()
      require('barbar').setup({
        animation = false,
        auto_hide = false,
        clickable = true,
        exclude_ft = {'NvimTree'},
        exclude_name = {},
        icons = {
          button = '',
          filetype = {
            enabled = true,
          },
        },
      })
    end,
  },
  
  -- LSP Configuration (intentionally without Mason to keep it minimal and simple)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Configure individual LSP servers
      -- You'll need to install these manually via your system package manager
      -- or use language-specific package managers

      -- Python LSP (install: pip install pyright)
      vim.lsp.config.pyright = {
        capabilities = capabilities,
      }

      -- Go LSP (install: go install golang.org/x/tools/gopls@latest)
      vim.lsp.config.gopls = {
        capabilities = capabilities,
      }

      -- Ruby LSP (install: gem install solargraph)
      vim.lsp.config.solargraph = {
        capabilities = capabilities,
      }

      -- Lua LSP (install: brew install lua-language-server on macOS)
      vim.lsp.config.lua_ls = {
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
      }

      -- HTML LSP (install: npm install -g vscode-langservers-extracted)
      vim.lsp.config.html = {
        capabilities = capabilities,
      }

      -- CSS LSP (install: npm install -g vscode-langservers-extracted)
      vim.lsp.config.cssls = {
        capabilities = capabilities,
      }

      -- JSON LSP (install: npm install -g vscode-langservers-extracted)
      vim.lsp.config.jsonls = {
        capabilities = capabilities,
      }

      -- TypeScript/JavaScript LSP (install: npm install -g typescript typescript-language-server)
      vim.lsp.config.ts_ls = {
        capabilities = capabilities,
      }

      vim.lsp.config.dockerls = {
        capabilities = capabilities,
      }

      vim.lsp.config.helm_ls = {
        capabilities = capabilities,
        filetypes = { "helm" },
        settings = {
          ['helm-ls'] = {
            yamlls = {
              path = "yaml-language-server",
              enabled = false,
            }
          }
        }
      }

      -- Tailwind CSS LSP (install: npm install -g @tailwindcss/language-server)
      vim.lsp.config.tailwindcss = {
        capabilities = capabilities,
      }

      -- YAML LSP (install: npm install -g yaml-language-server)
      vim.lsp.config.yamlls = {
        capabilities = capabilities,
        filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
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
        on_attach = function(client, bufnr)
          local filetype = vim.bo[bufnr].filetype
          if filetype == "helm" then
            vim.lsp.stop_client(client.id)
          end
        end,
      }

      -- Terraform LSP (install: brew install terraform-ls on macOS, or download from HashiCorp)
      vim.lsp.config.terraformls = {
        capabilities = capabilities,
      }

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
        formatting = {
          format = function(entry, vim_item)
            -- Replace source names with custom text/icons
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              copilot = "[CMP]",
              buffer = "[Buf]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
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
        experimental = {
          ghost_text = true,
        },
      })

      -- Setup copilot-cmp after cmp
      require("copilot_cmp").setup()
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
        workspace_folders = {
          "/Users/xcfw/dev/",
          "/Users/xcfw/tools/",
          "/Users/xcfw/.config/"
        },
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

  -- Auto-pairing brackets, quotes, etc.
  {
    "echasnovski/mini.pairs",
    version = "*",
    config = function()
      require("mini.pairs").setup({
        mappings = {
          ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^`\\].', register = { cr = false } },
        }
      })
    end,
  },

  -- Smooth movement animations
  {
    "echasnovski/mini.animate",
    version = "*",
    config = function()
      require("mini.animate").setup({
        scroll = {
          timing = function(_, n) return math.min(250 / n, 10) end,
        },
      })
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

  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons' -- or 'echasnovski/mini.nvim'
    },
    opts = {},
  },

  -- Auto-reload buffers when files change on disk (for Claude Code)
  {
    "diogo464/hotreload.nvim",
    event = "VeryLazy",
    opts = {
      interval = 1000,  -- Check every 500ms
    },
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
          dockerfile = { "hadolint" },
          terraform = { "terraform_fmt" },
          tf = { "terraform_fmt" },
          hcl = { "terragrunt_hclfmt" },
          helm = { "yamlfmt" },
        },
        formatters = {
          hadolint = {
            command = "hadolint",
            args = { "--format", "json", "$FILENAME" },
            stdin = false,
          },
          terragrunt_hclfmt = {
            command = "terragrunt",
            args = { "hclfmt", "--terragrunt-hclfmt-file", "$FILENAME" },
            stdin = false,
          },
        },
        format_on_save = nil,  -- Disabled by default, use manual formatting with <space>f
        format_after_save = nil,
      })
    end,
  },
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

