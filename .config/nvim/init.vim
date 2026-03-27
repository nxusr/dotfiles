call utils#SourceIfExists('local/pre.vim')

" options {

syntax enable

set noshowmode
set modeline

set number
set nowrap
set showmatch

set ignorecase
set smartcase

set noexpandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4

set autowrite
set autochdir


set nobackup
set noswapfile
set writebackup

set shortmess+=I

set clipboard+=unnamedplus

set lazyredraw
set cursorline

set mouse=a

set termguicolors
set background=dark
let base16colorspace=256
colorscheme base16-default-dark
lua <<EOF
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- Optional: Apply to other highlights
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
EOF

" }

" bindings {

nnoremap <c-t> :tabnew<cr>
nnoremap <c-left> :tabprev<cr>
nnoremap <c-right> :tabnext<cr>
nnoremap <F1> <nop>
inoremap <F1> <nop>
nnoremap Q <nop>
inoremap <C-Space> <Esc>

nmap <F2> :call nonprint#toggle()<cr>

" }

" plugins {

" automatically install plug.vim
if empty(glob('$XDG_DATA_HOME/nvim/site/autoload/plug.vim'))
	silent !curl -fLo $XDG_DATA_HOME/nvim/site/autoload/plug.vim --create-dirs
	\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall
endif

call plug#begin('$XDG_DATA_HOME/nvim/site/bundle')
let g:plug_timeout=120
let g:plug_window='tabnew'

" bundled
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_altv = 1
let g:netrw_winsize = 25

" navigation
Plug 'tpope/vim-rsi'
Plug 'tpope/vim-unimpaired'

" utilities
let g:lightline = {
	\ 'colorscheme': 'base16',
	\ }
Plug 'itchyny/lightline.vim'
	set laststatus=2
Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle' }
	nmap <F6> :TagbarToggle<cr>
Plug 'tpope/vim-surround'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-commentary'
	autocmd FileType spec setlocal commentstring=#\ %s

" search
Plug 'jremmen/vim-ripgrep', { 'on': 'Rg' }

" lsp: lint, completion, formatting
Plug 'dense-analysis/ale'
	let g:ale_floating_preview = 1
	let g:ale_open_list = 1
	let g:ale_sign_column_always = 1
	let g:ale_sign_error = "\u2622"
	let g:ale_sign_warning = "\u26a0"
	let g:ale_fix_on_save = 1
	nmap <silent> <C-k> <Plug>(ale_next_wrap)
	nmap <silent> <C-j> <Plug>(ale_previous_wrap)
	nmap <F3> :ALEFix<cr>
	nnoremap <silent> K :ALEHover<CR>
	nnoremap <silent> gd :ALEGoToDefinition<CR>
	nnoremap <M-LeftMouse> <LeftMouse>:ALEGoToDefinition<CR>
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
	let g:deoplete#enable_at_startup = 1
	inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" languages
Plug 'kballard/vim-fish'
	autocmd FileType fish compiler fish
	autocmd FileType fish setlocal textwidth=79
	autocmd FileType fish setlocal foldmethod=expr
Plug 'chase/vim-ansible-yaml'
Plug 'pangloss/vim-javascript'
Plug 'kchmck/vim-coffee-script'
Plug 'leshill/vim-json'
Plug 'othree/html5.vim'
Plug 'mutewinter/nginx.vim'
Plug 'Chiel92/vim-autoformat'
Plug 'rust-lang/rust.vim'
	let g:rustfmt_autosave = 1
Plug 'cespare/vim-toml'
Plug 'ledger/vim-ledger'
Plug 'plasticboy/vim-markdown'
Plug 'darfink/vim-plist'
	let g:plist_json_filetype = 'json'
Plug 'Peaches491/vim-glog-syntax'
Plug 'solarnz/thrift.vim'
Plug 'inkarkat/diff-fold.vim'
Plug 'vim-python/python-syntax'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
lua <<EOF
	vim.api.nvim_create_autocmd('FileType', {
	  pattern = { '<filetype>' },
	  callback = function() vim.treesitter.start() end,
	})
EOF

" flutter
Plug 'nvim-lua/plenary.nvim'
Plug 'stevearc/dressing.nvim' " optional for vim.ui.select
Plug 'nvim-flutter/flutter-tools.nvim'

call utils#SourceIfExists('local/plug.vim')

call plug#end()

call deoplete#custom#source('_', 'matchers', ['matcher_full_fuzzy'])
call deoplete#custom#option('sources', {'_': ['ale'] })

" }

call utils#SourceIfExists('local/post.vim')
