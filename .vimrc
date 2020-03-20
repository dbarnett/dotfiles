scriptencoding utf-8
set nocompatible

" BASIC CONFIGURATION {{{1

" Disable 'request cursor position' to avoid ^[[2;2R junk.
set t_u7=

set nomodeline
set wildmode=longest,list
set autoindent
set scrolloff=2
syntax on
filetype plugin indent on
set listchars=tab:»\ ,extends:@,precedes:^
set list
set incsearch
set hlsearch
if exists('g:gnvim')
  set guifont=Monospace:h11
endif
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
set spell

silent !mkdir -p ~/.vim/swaps
set directory=~/.vim/swaps
silent !mkdir -p ~/.vim/backups
set backupdir=~/.vim/backups

if &term =~ '^screen'
  " tmux will send xterm-style keys when its xterm-keys option is on
  execute "set <xUp>=\e[1;*A"
  execute "set <xDown>=\e[1;*B"
  execute "set <xRight>=\e[1;*C"
  execute "set <xLeft>=\e[1;*D"
endif

augroup my_settings
  au BufNewFile,BufRead * setlocal formatoptions-=o fo+=l
  au FileType * setlocal formatoptions-=o fo+=l
  " These are sane settings for any structured filetype
  " See http://stackoverflow.com/questions/12983409/ on programming filetypes
  au FileType * if &ft !=# 'text' && &ft !=# 'gitcommit' | setlocal formatoptions-=t fo+=crq | endif
augroup END

if !exists('A8_EMBEDDED')
  let g:confirm_quit = 1  " confirm quit only in a8
endif

" END BASIC CONFIGURATION }}}1

" MAPPINGS {{{1

let g:mapleader = ','

" Clear search highlight with redraw mapping.
nnoremap <C-L> :nohlsearch<CR><C-L>

" END MAPPINGS }}}1

" PLUGINS {{{1

call plug#begin('~/.vim/plugged')

" CORE PLUGINS (maktaba, vimproc.vim) {{{2

Plug 'google/vim-maktaba'
Plug 'google/vim-glaive'
Plug 'Shougo/vimproc.vim', {'do' : 'make'}

" END CORE PLUGINS }}}2

" FILETYPES {{{2

Plug 'vim-scripts/syntaxconkyrc.vim'
Plug 'dart-lang/dart-vim-plugin'
Plug 'google/vim-ft-vroom'
Plug 'PotatoesMaster/i3-vim-syntax'
Plug 'duganchen/vim-soy'
Plug 'zaiste/tmux.vim'
Plug 'cespare/vim-toml'
Plug 'leafgarland/typescript-vim'
Plug 'junegunn/vader.vim'

" END FILETYPES }}}2

" AMENITIES (projectionist, unimpaired) {{{2

Plug 'ciaranm/securemodelines'
Plug 'editorconfig/editorconfig-vim'

Plug 'sjl/gundo.vim'
let g:gundo_preview_bottom = 1
nnoremap <F5> :GundoToggle<CR>
"Plug 'embear/vim-localvimrc'
" let g:localvimrc_whitelist='/some/path/'

Plug 'tpope/vim-projectionist'
let g:projectionist_heuristics = {
    \ 'plugin/*.vim|autoload/**/*.vim|addon-info.json': {
    \     'addon-info.json': {
    \         'command': 'meta',
    \         'template': ['{', '  "description": "",', '  "dependencies": {}', '}'],
    \     },
    \     'plugin/*.vim': {'command': 'plugin'},
    \     'instant/*.vim': {'command': 'instant'},
    \     'autoload/*.vim': {'command': 'autoload'},
    \     'doc/*.txt': {'command': 'doc'},
    \     'README.(markdown|md)': {'command': 'doc'},
    \     'vroom/*.vroom': {'command': 'test'}
    \     },
    \ }

"Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-unimpaired'

" END AMENITIES }}}2

" EDITOR UTILS (abolish, bracketed-paste) {{{2

Plug 'tpope/vim-abolish'
Plug 'ConradIrwin/vim-bracketed-paste'
Plug 'kana/vim-textobj-user'
Plug 'Julian/vim-textobj-variable-segment'
Plug 'google/vim-syncopate'

" END EDITOR UTILS }}}2

" MODES (vtd, vinegar) {{{2

Plug 'chiphogg/vim-vtd'

" Workaround for https://github.com/tpope/vim-vinegar/issues/63 (clobbering -).
nnoremap - -
Plug 'tpope/vim-vinegar'

" END MODES }}}2

" BASIC DEVTOOLS (dispatch, neomake, bazel, snippets) {{{2
" Provide commands and simple helpers.

Plug 'tpope/vim-dispatch'
Plug 'neomake/neomake'

Plug 'google/vim-codefmt'
Plug 'google/vim-codereview'
Plug 'honza/vim-snippets'

Plug 'janko/vim-test'
let test#runner_commands = ['Nose']

if has('python')
  Plug 'SirVer/ultisnips'
  let g:UltiSnipsEditSplit = 'vertical'
endif

Plug 'http://repo.or.cz/vcscommand.git'
let g:VCSCommandSplit = 'vertical'
let g:VCSCommandDisableMappings = 1

" bazel
Plug 'bazelbuild/vim-bazel'

" HTML/XML
Plug 'mattn/emmet-vim'

" vimscript
Plug 'tpope/vim-scriptease'

" END BASIC DEVTOOLS }}}2

" LINTERS/VISUALIZERS (signify, ale) {{{2

Plug 'google/vim-coverage'
Plug 'mhinz/vim-signify'

Plug 'dense-analysis/ale'
let g:ale_linters = {
    \ 'python': ['pyflakes']}

Plug 'syngan/vim-vimlint'
Plug 'ynkdir/vim-vimlparser'

" END LINTERS/VISUALIZERS }}}2

" ADVANCED DEVTOOLS (vebugger, LSP) {{{2
" Extend overall vim functionality.

Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-emoji.vim'

augroup asyncomplete_setup
  au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#emoji#get_source_options({
    \ 'name': 'emoji',
    \ 'whitelist': ['*'],
    \ 'completor': function('asyncomplete#sources#emoji#completor'),
    \ }))
augroup END

augroup lsp_setup
  if (executable('pyls'))
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python']
        \ })
  endif
augroup END

nnoremap gd :LspDefinition<CR>
nnoremap <F4> :LspReferences<CR>
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR>    pumvisible() ? "\<C-y>" : "\<CR>"
imap <C-Space> <Plug>(asyncomplete_force_refresh)

Plug 'idanarye/vim-vebugger'
let g:vebugger_leader='<Leader>d'

" END ADVANCED DEVTOOLS }}}2

call plug#end()

" Workaround for https://github.com/tpope/vim-sleuth/issues/29.
" Define autocmd as early as possible so other autocmds can override.
runtime! plugin/sleuth.vim

call maktaba#plugin#Detect()

call glaive#Install()
Glaive syncopate plugin[mappings]

" END PLUGINS }}}1

" CUSTOM UTILS / MAPPINGS (VC, ToggleFoldIndent) {{{1

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

nmap <F8> :call ToggleFoldIndent()<CR>
"nnoremap <silent> <F8> :TlistToggle<CR>

" END CUSTOM UTILS }}}1

" vim:fdm=marker:sw=2:sts=2:ts=2:et:tw=100
