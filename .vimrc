if !has('gui_running')
    let b:did_pyflakes_plugin = 1   " disable pyflakes (looks horrible in term)
endif
if !exists('A8_EMBEDDED')
    let g:confirm_quit = 1  " confirm quit only in a8
endif
let g:gundo_preview_bottom = 1
call pathogen#infect()
set modeline
set modelines=5
syntax on
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

nnoremap <F5> :GundoToggle<CR>
nmap <F3> :NERDTreeToggle<CR>
nmap <F8> :call ToggleFoldIndent()<CR>
"nnoremap <silent> <F8> :TlistToggle<CR>

" set up project code style settings for local project dirs
source ~/.vim/local_code_style_settings.vim
