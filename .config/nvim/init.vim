call utils#SourceIfExists('local/pre.vim')

" options {

set noshowmode

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
lua <<EOF
vim.g.clipboard = 'osc52'
EOF

set cursorline

set mouse=a

set termguicolors
set background=dark
colorscheme base16-default-dark
lua <<EOF
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
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
Plug 'ledger/vim-ledger'
Plug 'darfink/vim-plist'
	let g:plist_json_filetype = 'json'
Plug 'Peaches491/vim-glog-syntax'
Plug 'inkarkat/diff-fold.vim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
lua <<EOF
	vim.api.nvim_create_autocmd('FileType', {
	  callback = function() pcall(vim.treesitter.start) end,
	})
EOF

call utils#SourceIfExists('local/plug.vim')

call plug#end()

call deoplete#custom#source('_', 'matchers', ['matcher_full_fuzzy'])
call deoplete#custom#option('sources', {'_': ['ale'] })

" }

call utils#SourceIfExists('local/post.vim')
