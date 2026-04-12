local config_dir = vim.fn.stdpath('config')
pcall(dofile, config_dir .. '/local/pre.lua')

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

vim.g.mapleader = ' '

-- display
vim.opt.showmode = false
vim.opt.number = true
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.showbreak = '↪ '
vim.opt.showmatch = true
vim.opt.cursorline = true
vim.opt.signcolumn = 'yes'
vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.opt.shortmess:append('I')

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- indentation
vim.opt.expandtab = false
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- files
vim.opt.autoread = true
vim.opt.autowrite = true
vim.opt.autochdir = true
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.writebackup = true

-- input
vim.opt.mouse = 'a'
vim.opt.clipboard:append('unnamedplus')
vim.g.clipboard = 'osc52'

--------------------------------------------------------------------------------
-- Keymaps
--------------------------------------------------------------------------------

vim.keymap.set('n', '<C-t>', '<cmd>tabnew<CR>')
vim.keymap.set('n', '<C-Left>', '<cmd>tabprev<CR>')
vim.keymap.set('n', '<C-Right>', '<cmd>tabnext<CR>')
vim.keymap.set('n', '<F1>', '<Nop>')
vim.keymap.set('i', '<F1>', '<Nop>')
vim.keymap.set('n', 'Q', '<Nop>')
vim.keymap.set('i', '<C-Space>', '<Esc>')
vim.keymap.set('n', '<C-k>', function() vim.diagnostic.jump({ count = 1 }) end)
vim.keymap.set('n', '<C-j>', function() vim.diagnostic.jump({ count = -1 }) end)


--------------------------------------------------------------------------------
-- Netrw
--------------------------------------------------------------------------------

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_altv = 1
vim.g.netrw_winsize = 25

--------------------------------------------------------------------------------
-- Autocmds
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd({'FocusGained', 'BufEnter', 'CursorHold'}, {
	command = 'checktime',
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'spec',
  callback = function() vim.bo.commentstring = '# %s' end,
})

vim.filetype.add({
  filename = { TARGETS = 'starlark', BUCK = 'starlark' },
  extension = { cconf = 'python', mcconf = 'python', cinc = 'python', pyx = 'python', pxd = 'python', tw = 'python' },
})

--------------------------------------------------------------------------------
-- Bootstrap lazy.nvim
--------------------------------------------------------------------------------

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------------------------------
-- Plugins
--------------------------------------------------------------------------------

local nerd_symbol_icons = {
  Class         = '󰠱',
  Color         = '󰏘',
  Constant      = '󰏿',
  Constructor   = '󰒓',
  Enum          = '󰕘',
  EnumMember    = '󰕘',
  Event         = '󰉁',
  Field         = '󰜢',
  File          = '󰈙',
  Folder        = '󰉋',
  Function      = '󰊕',
  Interface     = '󰜰',
  Keyword       = '󰌋',
  Method        = '󰆧',
  Module        = '󰆧',
  Namespace     = '󰌗',
  Operator      = '󰆕',
  Property      = '󰖷',
  Reference     = '󰈇',
  Snippet       = '󰩫',
  Struct        = '󰙅',
  Text          = '󰉿',
  TypeParameter = '󰊄',
  Unit          = '󰑭',
  Value         = '󰎠',
  Variable      = '󰀫',
}

local unicode_symbol_icons = {
  Class         = '◆',
  Color         = '●',
  Constant      = 'π',
  Constructor   = '⬡',
  Enum          = '❖',
  EnumMember    = '▪',
  Event         = '↯',
  Field         = '◇',
  File          = '□',
  Folder        = '▤',
  Function      = 'λ',
  Interface     = '◎',
  Keyword       = '⊞',
  Method        = '→',
  Module        = '◫',
  Namespace     = '▣',
  Operator      = '±',
  Property      = '◇',
  Reference     = '⊕',
  Snippet       = '✂',
  Struct        = '◈',
  Text          = '¶',
  TypeParameter = '⊟',
  Unit          = '↕',
  Value         = '∎',
  Variable      = 'α',
}

local use_nerd_font = vim.g.use_nerd_font or false
local symbol_icons = use_nerd_font and nerd_symbol_icons or unicode_symbol_icons

local plugins = {
  -- navigation
  'tpope/vim-rsi',
  'tpope/vim-unimpaired',

  -- editing
  'tpope/vim-surround',
  'tpope/vim-endwise',

  -- ui
  { 'nvim-lualine/lualine.nvim', opts = {} },
  {
    'stevearc/aerial.nvim',
    lazy = false,
    keys = { { '<F6>', '<cmd>AerialToggle<CR>' } },
    opts = {
      backends = { 'lsp', 'treesitter', 'markdown', 'asciidoc', 'man' },
      attach_mode = 'global',
      open_automatic = true,
      layout = { min_width = 40 },
      show_guides = true,
      filter_kind = {
        'Class', 'Constructor', 'Enum', 'Function', 'Interface',
        'Module', 'Method', 'Namespace', 'Struct',
      },
      icons = symbol_icons,
    },
  },

  -- search
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    keys = {
      { '<leader>tf', '<cmd>Telescope find_files<CR>' },
      { '<leader>tg', '<cmd>Telescope live_grep<CR>' },
      { '<leader>tb', '<cmd>Telescope buffers<CR>' },
      { '<leader>td', '<cmd>Telescope diagnostics<CR>' },
      { '<leader>tD', '<cmd>Telescope diagnostics bufnr=0<CR>' },
    },
    config = function()
      require('telescope').load_extension('fzf')
    end,
  },

  -- lsp
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      vim.lsp.config('*', {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      })

      require('mason').setup()
      require('mason-lspconfig').setup()

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<M-LeftMouse>', '<LeftMouse><cmd>lua vim.lsp.buf.definition()<CR>', opts)
        end,
      })
    end,
  },

  -- completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        snippet = {
          expand = function(args) vim.snippet.expand(args.body) end,
        },
        formatting = {
          format = function(_, vim_item)
            vim_item.kind = (symbol_icons[vim_item.kind] or '?') .. ' ' .. vim_item.kind
            return vim_item
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })

      cmp.setup.filetype({ 'text', 'markdown' }, { enabled = false })
    end,
  },

  -- linting (non-LSP sources)
  {
    'nvimtools/none-ls.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },

  -- formatting
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    keys = { { '<F3>', function() require('conform').format() end } },
    opts = {
      format_on_save = function(bufnr)
        if vim.bo[bufnr].filetype == 'hack' then return false end
        return { timeout_ms = 500, lsp_format = 'fallback' }
      end,
      formatters_by_ft = {
        rust = { 'rustfmt' },
        javascript = { 'prettier' },
        python = { 'black' },
      },
    },
  },

  -- treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install({
        'bash', 'c', 'cpp', 'css',
        'go', 'hack', 'html',
        'javascript', 'json', 'lua',
        'markdown', 'markdown_inline',
        'python', 'rust', 'starlark',
        'thrift', 'toml', 'yaml',
      })
      vim.api.nvim_create_autocmd('FileType', {
        callback = function() pcall(vim.treesitter.start) end,
      })
    end,
  },

  -- languages
  'ledger/vim-ledger',
  { 'darfink/vim-plist', init = function() vim.g.plist_json_filetype = 'json' end },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = 'markdown',
    opts = {},
  },
  'Peaches491/vim-glog-syntax',
  'inkarkat/diff-fold.vim',
}

local ok, local_plugins = pcall(dofile, config_dir .. '/local/plugins.lua')
if ok and type(local_plugins) == 'table' then
  vim.list_extend(plugins, local_plugins)
end

require('lazy').setup(plugins)

--------------------------------------------------------------------------------
-- Colorscheme
--------------------------------------------------------------------------------

vim.cmd.colorscheme('b16-default-dark')

-- transparent background (inherit from terminal)
vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'none' })
vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })

-- nonprint highlight overrides
vim.api.nvim_set_hl(0, 'SpecialKey', { fg = '#7cafc2' })
vim.api.nvim_set_hl(0, 'Conceal', { fg = '#7cafc2', bg = 'none' })

--------------------------------------------------------------------------------
-- Diagnostics
--------------------------------------------------------------------------------

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '☢',
      [vim.diagnostic.severity.WARN] = '⚠',
    },
  },
})

--------------------------------------------------------------------------------
-- Local post-hook
--------------------------------------------------------------------------------

pcall(dofile, config_dir .. '/local/post.lua')
