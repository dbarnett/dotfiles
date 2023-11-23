scriptencoding utf-8
set nocompatible

" BASIC CONFIGURATION {{{1

" Disable 'request cursor position' to avoid ^[[2;2R junk.
set t_u7=

set nomodeline
set backspace=indent,eol,start
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
set shiftwidth=2 tabstop=2 softtabstop=2 expandtab

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

Plug 'junegunn/vim-plug'
Plug 'google/vim-maktaba'
Plug 'google/vim-glaive'
Plug 'Shougo/vimproc.vim', {'do' : 'make'}

if has('nvim')
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-tree/nvim-web-devicons'
endif

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

let g:markdown_fenced_languages = [
    \ 'c',
    \ 'cpp',
    \ 'diff',
    \ 'python',
    \ 'bash=sh',
    \ 'java',
    \ 'json',
    \ 'shell=sh',
    \ 'VimL=vim',
    \ 'xml',
    \ 'yaml',
    \ ]

" END FILETYPES }}}2

" AMENITIES (projectionist, unimpaired) {{{2
" Plugins that broadly affect the editor environment.

Plug 'ciaranm/securemodelines'
Plug 'editorconfig/editorconfig-vim'

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
Plug 'tpope/vim-surround'

Plug 'lotabout/skim', { 'dir': '~/.skim', 'do': './install' }
Plug 'lotabout/skim.vim'

if has('nvim')
  Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
endif

" END AMENITIES }}}2

" EDITOR UTILS (abolish, bracketed-paste) {{{2
" Plugins that add self-contained editor utilities to invoke.

Plug 'tpope/vim-abolish'
Plug 'ConradIrwin/vim-bracketed-paste'
Plug 'kana/vim-textobj-user'
Plug 'Julian/vim-textobj-variable-segment'
Plug 'google/vim-syncopate'

" END EDITOR UTILS }}}2

" MODES (vtd, vinegar) {{{2

if !has('nvim')
  Plug 'chiphogg/vim-vtd'
endif

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
Plug 'AndrewRadev/splitjoin.vim'
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
     \ 'python': ['pyls'],
     \ }

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
   \ 'allowlist': ['*'],
   \ 'completor': function('asyncomplete#sources#emoji#completor'),
   \ }))
augroup END

if isdirectory(expand('~/.log'))
  " Uncomment this if troubleshooting LSP.
  "let g:lsp_log_verbose = 1
  let g:lsp_log_file = expand('~/.log/vim-lsp.log')
endif
let g:lsp_diagnostics_enabled = 0

" See also: config in vim-lsp-settings settings.json.
augroup lsp_setup
  if (executable('pyls'))
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'allowlist': ['python']
        \ })
  endif
augroup END

nnoremap gd :LspDefinition<CR>
nnoremap <F4> :LspReferences<CR>
imap <C-Space> <Plug>(asyncomplete_force_refresh)

Plug 'idanarye/vim-vebugger'
let g:vebugger_leader='<Leader>d'

" END ADVANCED DEVTOOLS }}}2

call plug#end()

" Workaround for https://github.com/tpope/vim-sleuth/issues/29.
" Define autocmd as early as possible so other autocmds can override.
"runtime! plugin/sleuth.vim

call maktaba#plugin#Detect()

call glaive#Install()
Glaive syncopate plugin[mappings]

" END PLUGINS }}}1

" CUSTOM UTILS / MAPPINGS (e.g., fold shortcuts) {{{1

" Jump between windows with Ctrl-arrow
nnoremap <C-Up> <C-W><Up>
nnoremap <C-Left> <C-W><Left>
nnoremap <C-Down> <C-W><Down>
nnoremap <C-Right> <C-W><Right>

""
" Define a short-lived vim mapping from {lhs} to {rhs} in {mode}.
" This is used to support an improved replacement for 'timeout' behavior where a
" mapping should do one thing instantly but "change its mind" and do something
" else if another key is pressed immediately.
"
" For example, this defines a mapping that immediately unfolds one level but
" unfolds all levels if the ">" keypress is repeated: >
"   nnoremap z> zr:call TimeoutMapping('nnore', '>', 'zR')<CR>
" <
function TimeoutMapping(mode, lhs, rhs) abort
  " Define short-lived <buffer> mapping.
  execute a:mode.'map <buffer> <nowait> <silent>' a:lhs a:rhs

  " Schedule it to be deleted after timeout.
  let l:basemode = substitute(a:mode, '\mnore$', '', '')
  let l:unmap_cmd = printf('silent %sunmap <buffer> %s', l:basemode, a:lhs)
  call timer_start(&timeoutlen, {tid -> execute(l:unmap_cmd)})
endfunction

" z> unfolds one level (w/ no delay) and z>> opens all folds.
" z< does the reverse.
nnoremap <silent> z> zr:call TimeoutMapping('nnore', '>', 'zR')<CR>
nnoremap <silent> z< zm:call TimeoutMapping('nnore', '<', 'zM')<CR>

" END CUSTOM UTILS }}}1

" vim:fdm=marker:sw=2:sts=2:ts=2:et:tw=100
