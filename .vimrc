if !has('gui_running')
	let b:did_pyflakes_plugin = 1	" disable pyflakes (looks horrible in term)
endif
call pathogen#infect()
set sw=4 ts=4 sts=4 noexpandtab
set modeline
set modelines=5
filetype on
filetype plugin on
colorscheme slate

function ToggleFoldIndent()
	if &foldmethod == 'indent'
		set foldlevel=999
		set foldmethod=manual
	else
		set foldmethod=indent
		set foldminlines=5
		set foldnestmax=3
		set foldlevel=0
	endif
endfunction

nmap <F8> :call ToggleFoldIndent()<CR>
"nnoremap <silent> <F8> :TlistToggle<CR>

" set up project code style settings for local project dirs
source ~/.vim/local_code_style_settings.vim
