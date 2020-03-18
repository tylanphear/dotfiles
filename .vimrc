set nocompatible
filetype off

if v:version >= 800
    set rtp+=~/.vim/bundle/Vundle.vim
    call vundle#begin()

    Plugin 'VundleVim/Vundle.vim'
    Plugin 'tpope/vim-fugitive'
    Plugin 'wincent/command-t'
    Plugin 'vim-scripts/a.vim'
    Plugin 'Valloric/YouCompleteMe'
    Plugin 'rdnetto/YCM-Generator'

    call vundle#end()

    " Remap man lookup to something useful
    nnoremap K :YcmCompleter GoToDefinition<CR>

    let g:ycm_global_ycm_extra_conf = "$HOME/.ycm_extra_conf.py"
    let g:ycm_confirm_extra_conf = 0

    let g:ycm_rls_binary_path = exepath("rls")

    let g:ycm_clangd_uses_ycmd_caching = 0
    let g:ycm_clangd_binary_path = exepath("clangd")
    let g:ycm_clangd_args = ['-clang-tidy', '--all-scopes-completion']

    let g:ycm_min_num_of_chars_for_completion = 4
    let g:ycm_enable_diagnostic_highlighting = 0
    let g:ycm_always_populate_location_list = 1

    let g:CommandTFileScanner = 'git'

    map <C-h> :AS<CR>
endif

filetype plugin indent on

if has("autocmd")
    " Make needs tabs
    autocmd FileType make set tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab
    " Highlight trailing space in diffs
    autocmd FileType diff highlight RedundantSpaces ctermbg=red guibg=red 
    autocmd FileType diff match RedundantSpaces /\s\+$/
endif

if has("terminal")
    set termwinsize=0*2000

    nnoremap ,r :term rg --no-heading 
    nnoremap ,f :term fd 
endif

" Make bell shut up
set visualbell t_vb=

" Line numbers are great
set number
" See where the cursor is
set ruler

" Syntax highlighting isn't on by default for some reason
syntax on
" Make backspace (great again!) work as expected in insert mode
set backspace=indent,eol,start

" Basic formatting stuff for languages I don't have specific rules for
set softtabstop=4 shiftwidth=4 expandtab autoindent

" Always show filename
set laststatus=2

" Encoding stuff... fun
set encoding=utf-8
set fileencodings=latin1,utf-8,sjis
set fileformats=unix,dos,mac

set winminheight=0
set completeopt-=preview

set directory=$HOME/.vim/swapfiles//

" Allow bash aliases/functions from vim
set shellcmdflag=-ic

" Y normally does yy, this makes it consistent with D and C
map Y y$
