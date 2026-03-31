setlocal expandtab
" ale settings
let b:ale_fixers = ['rustfmt']
let b:ale_rust_cargo_use_check = 1

" use quickfix instead of location list since errors span across files
" NOTE: ale_set_loclist and ale_set_quickfix are global-only, no buffer-local equivalent
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1

call utils#SourceIfExists('local/rust.vim')
