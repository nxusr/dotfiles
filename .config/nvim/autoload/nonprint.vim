" vim: foldmethod=marker foldlevel=0

if !exists('g:nonprint#has_setup')

	let g:nonprint#enabled = 0

	if !exists('g:nonprint#listchars')
		let g:nonprint#listchars='eol:¬,tab:>-,trail:.,extends:>,precedes:<,nbsp:.'
	endif
	let &listchars=g:nonprint#listchars

	highlight SpecialKey ctermfg=12 guifg=#7cafc2

	if has('conceal')
		setlocal conceallevel=2 concealcursor=inv
		highlight Conceal ctermbg=none ctermfg=12 guibg=none guifg=#7cafc2
	endif

	let g:nonprint#has_setup = 1


	function! nonprint#enable()
		if g:nonprint#enabled == 1
			return
		endif

		set list
		if has('conceal')
			syntax match LeadingSpaces /\(^ *\)\@<= / containedin=ALL conceal cchar=.
		endif

		let g:nonprint#enabled = 1
	endfunction

	function! nonprint#disable()
		if g:nonprint#enabled == 0
			return
		endif

		set nolist
		if has('conceal')
			syntax clear LeadingSpaces
		endif

		let g:nonprint#enabled = 0
	endfunction

	function! nonprint#toggle()
		if g:nonprint#enabled == 0
			call nonprint#enable()
		else
			call nonprint#disable()
		endif
	endfunction

endif
