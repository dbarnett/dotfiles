if !has('gui_running')
    let b:did_pyflakes_plugin = 1   " disable pyflakes (looks horrible in term)
endif
if !exists('A8_EMBEDDED')
    let g:confirm_quit = 1  " confirm quit only in a8
endif
let g:gundo_preview_bottom = 1

let g:syntastic_check_on_open = 1
let g:syntastic_mode_map = {
    \ 'mode': 'passive',
    \ 'active_filetypes': ['python'] }

" g:localvimrc_whitelist defined in local_code_style_settings.vim

let g:UltiSnipsEditSplit='vertical'

call pathogen#infect()
set modeline
set modelines=5
set wildmode=longest,list
syntax on
filetype on
filetype plugin on
colorscheme slate
set listchars=tab:»\ ,extends:@,precedes:^
set list

au FileType python,html setlocal formatoptions=crql
au BufNewFile,BufRead * setlocal formatoptions+=l formatoptions-=o

function! ToggleFoldIndent()
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

silent !mkdir -p ~/.vim/swaps
set directory=~/.vim/swaps
silent !mkdir -p ~/.vim/backups
set backupdir=~/.vim/backups

nnoremap <F5> :GundoToggle<CR>
nmap <F3> :NERDTreeToggle<CR>
nmap <F8> :call ToggleFoldIndent()<CR>
"nnoremap <silent> <F8> :TlistToggle<CR>

" set up project code style settings for local project dirs
source ~/.vim/local_code_style_settings.vim
