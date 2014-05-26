set nocompatible

set runtimepath+=~/.vim/vim-addons/vim-addon-manager
call vam#ActivateAddons([])
VAMActivate maktaba abolish glaive localvimrc scriptease snippets Syntastic
    \ unimpaired UltiSnips vcscommand vim-signify github:google/vim-ft.vroom

if !exists('A8_EMBEDDED')
    let g:confirm_quit = 1  " confirm quit only in a8
endif
let g:gundo_preview_bottom = 1

let g:syntastic_check_on_open = 1
let g:syntastic_python_checkers = ['pyflakes']
let g:syntastic_mode_map = {
    \ 'mode': 'passive',
    \ 'active_filetypes': ['python'] }

" g:localvimrc_whitelist defined in local_code_style_settings.vim

let g:UltiSnipsEditSplit='vertical'
let g:VCSCommandSplit = 'vertical'

let g:VCSCommandDisableMappings = 1

let g:mapleader = ','
call pathogen#infect()

call glaive#Install()

set modeline
set modelines=5
set wildmode=longest,list
set autoindent
set scrolloff=2
syntax on
filetype plugin indent on
set listchars=tab:»\ ,extends:@,precedes:^
set list
set incsearch
set hlsearch
set colorcolumn=+1
augroup color_tweak
  autocmd ColorScheme * highlight ColorColumn ctermbg=5 guibg=DarkSlateGray
augroup END
colorscheme slate
" Looks better on dark backgrounds
highlight Search ctermbg=4
" Allow '@' in filenames (for gf and such)
set isfname+=@-@
set nojoinspaces

au BufNewFile,BufRead * setlocal formatoptions-=o fo+=l
au FileType * setlocal formatoptions-=o fo+=l
" These are sane settings for any structured filetype
" See http://stackoverflow.com/questions/12983409/ on programming filetypes
au FileType * if &ft !=# 'text' && &ft !=# 'gitcommit' | setlocal formatoptions-=t fo+=crq | endif

command -nargs=1 VC  call ExecuteVimCommandAndViewOutput(<q-args>)

function ExecuteVimCommandAndViewOutput(cmd)
    redir @v
    silent execute a:cmd
    redir END
    new
    set buftype=nofile
    put v
endfunction

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
