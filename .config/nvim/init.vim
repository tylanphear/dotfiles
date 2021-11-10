" If vim-plug is not installed, install it, run `PlugInstall` and re-source
let vim_plug_path = stdpath('data').'/site/autoload/plug.vim'
if empty(glob(vim_plug_path))
    silent execute '!curl -fLo '.vim_plug_path.' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(stdpath('data') . '/plugged')

Plug 'Glench/Vim-Jinja2-Syntax'
Plug 'rust-lang/rust.vim'
Plug 'kevinoid/vim-jsonc'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-abolish'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'jackguo380/vim-lsp-cxx-highlight'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'easymotion/vim-easymotion'
Plug 'micbou/a.vim'
Plug 'tylanphear/stanza.vim'

call plug#end()

let g:titlecase_exceptions = [
\   'if', 'else', 'elsif', 'then', 'begin', 'end',
\   'declare', 'case', 'when', 'exit', 'exception', 'raise',
\   'and', 'or', 'not', 'others', 'function', 'procedure',
\   'is', 'return', 'loop', 'for', 'while', 'in', 'out',
\   'reverse', 'null', 'type', 'record', 'package', 'body',
\   'access', 'aliased', 'pragma', 'with', 'use', 'renames',
\   'constant', 'integer', 'string', 'natural']

function! s:titlecase(additional_exceptions) range
    let l:exceptions = extend(g:titlecase_exceptions, a:additional_exceptions)
    function! s:make_title_word(word) closure
        if index(l:exceptions, a:word) >= 0
            return a:word
        endif
        let l:word = a:word
        let l:word = substitute(l:word, '_', ' ', 'g')
        let l:word = substitute(l:word, '\(\<\w\)\(\w*\)','\u\1\L\2', 'g')
        let l:word = substitute(l:word, ' ', '_', 'g')
        return l:word
    endfunction
    let l:lines = getline(a:firstline, a:lastline)
    let l:lines = map(l:lines, { _, line ->
                \     substitute(line, '\(\w\+\)', { m -> s:make_title_word(m[1])}, 'g')})
    call setline(a:firstline, l:lines)
endfunction

command! -nargs=* -range TitleCase <line1>,<line2>call <SID>titlecase([<f-args>])

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:show_documentation()
  if index(['vim', 'help'], &filetype) >= 0
    execute 'h ' . expand('<cword>')
  else
    call CocActionAsync('doHover')
  endif
endfunction

function! s:Exec(...) abort
    let l:args = map(copy(a:000), {_, arg -> expand(escape(arg, '\'))})
    new!
    exec 'terminal ' . join(l:args)
endfunction
command! -nargs=+ -complete=shellcmd Exec call <SID>Exec(<f-args>)

function! s:Build(...)
    execute "Exec build " . join(a:000)
endfunction
command! -nargs=* Build call <SID>Build(<f-args>)

function! s:BuildClean(...)
    execute "Exec build clean && build " . join(a:000)
endfunction
command! -nargs=* BuildClean call <SID>BuildClean(<f-args>)

let g:coc_snippet_next = '<tab>'
let g:alternativeNoDefaultAlternate = 1

nmap     <silent> K         <Plug>(coc-definition)
nmap     <silent> <Leader>r <Plug>(coc-references)
nmap     <silent> <Leader>R <Plug>(coc-rename)
nmap     <silent> <Leader>a <Plug>(coc-codeaction)
nmap     <silent> <Leader>f <Plug>(coc-fix-current)
nmap     <silent> g[        <Plug>(coc-diagnostic-prev)
nmap     <silent> g]        <Plug>(coc-diagnostic-next)
xmap     <silent> <Leader>f <Plug>(coc-format-selected)
nnoremap <silent> <Leader>t :Files<CR>
nnoremap <silent> <Leader>b :Buffers<CR>
nnoremap <silent> <Leader>d :call <SID>show_documentation()<CR>
nnoremap <silent> <C-h>     :AS<CR>
nnoremap <silent> ,b        :Build<CR>
nnoremap <silent> ,cb       :BuildClean<CR>
imap     <silent> <C-l>     <Plug>(coc-snippets-expand)
" Prevent this accidentally being triggered in visual mode
vnoremap          K         <NOP>

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

if exists('*complete_info')
  inoremap <expr> <CR> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

let fzf_action = {'ctrl-s': 'split'}

" Status line highlight groups
hi StatusFunction guibg=darkgreen  cterm=reverse,bold ctermbg=52
hi StatusError    guifg=red        cterm=reverse,bold ctermfg=red    ctermbg=white
hi StatusFile     guibg=darkblue   cterm=reverse,bold ctermbg=21
hi StatusWarning  guifg=yellow     cterm=reverse,bold ctermfg=yellow ctermbg=white

" Change popup menu to use grey
hi Pmenu ctermfg=0 ctermbg=grey guibg=grey

" Neovim default is to clear highlighting, this makes it like Vim
hi Visual cterm=reverse

function! CocDiagnosticNum(kind, marker) abort
    let info = get(b:, 'coc_diagnostic_info', {})
    if empty(info) | return '' | endif
    let num = get(info, a:kind, 0)
    if num > 0
        return a:marker . num
    endif
    return ''
endfunction

set statusline=
set statusline+=%#StatusError#%-3.3{CocDiagnosticNum('error','E')}%*
set statusline+=%#StatusWarning#%-3.3{CocDiagnosticNum('warning','W')}%*
set statusline+=%#StatusFile#%-.40f%*
set statusline+=\ %h%w%m%r
set statusline+=%#StatusFunction#%(\ %-.50((%{get(b:,'coc_current_function','')})%)%)%*
set statusline+=%=
set statusline+=%a
set statusline+=%(\ [%{trim(get(g:,'coc_status',''))}]%)
set statusline+=%=
set statusline+=%{&fileformat}\ \|\ %{&encoding}\ %y\ 
set statusline+=%-9((%l,%c%V)%)\ %P

function! s:HighlightSpaces()
    highlight RedundantSpaces ctermbg=red guibg=red 
    match RedundantSpaces /.\zs\s\+$/ " \zs sets start of match
endfunction
command! HighlightSpaces call <SID>HighlightSpaces()
command! NoHighlightSpaces match none

function! s:PrintSynStack()
    echo map(synstack(line("."), col(".")), {_, val -> synIDattr(val, "name")})
endfunction
map <Leader>D :call <SID>PrintSynStack()<CR>

augroup Term
    autocmd!
    autocmd TermOpen * setlocal nonumber statusline=%#StatusFile#%f%* nohidden scrollback=100000
    autocmd TermOpen * normal! G
augroup END
augroup make
" Make needs tabs
    autocmd!
    autocmd FileType make setlocal tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab
augroup END
augroup Diff
" Highlight trailing space in diffs
    autocmd!
    autocmd FileType diff HighlightSpaces
augroup END
augroup Ada
    autocmd!
    autocmd FileType ada setlocal tabstop=3 softtabstop=3 shiftwidth=3 expandtab autoindent smarttab
augroup END
augroup Cpp
    autocmd!
    autocmd FileType c,cpp setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab autoindent smarttab
augroup END
augroup Python
    autocmd!
    autocmd FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab autoindent smarttab
    autocmd FileType python nnoremap <buffer> <C-H> :split %:r.md<CR>
augroup END
augroup Markdown
    autocmd!
    autocmd FileType markdown nnoremap <buffer> <C-H> :split %:r.py<CR>
augroup END
augroup YAML
    autocmd!
    autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab autoindent smarttab
augroup END
augroup Jinja
    autocmd!
    autocmd BufNewFile,BufRead *.html.template,*.txt.template set ft=jinja
    autocmd FileType jinja setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab autoindent smarttab
augroup END
augroup Stanza
    autocmd!
    autocmd FileType stanza setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab autoindent smarttab
augroup END

command! -nargs=+ -complete=file Rg call <SID>Exec('rg', '--color=always', '--vimgrep', <f-args>)
nnoremap ,r :Rg 

" Convenience commands for my fat fingers
command! -nargs=0 -bang W :w<bang>
command! -nargs=0 -bang Wq :wq<bang>

" Y normally does yy, this makes it consistent with D and C
map Y y$

" Whether or not we can have hidden buffers
set hidden

" Better response time
set updatetime=300
" Don't give completion menu messages
set shortmess+=c

" Where to put diagnostic signs
set signcolumn=number

" Make bell shut up
set visualbell t_vb=

" Line numbers are great
set number

" Syntax highlighting isn't on by default for some reason
syntax enable

" Make backspace (great again!) work as expected in insert mode
set backspace=indent,eol,start

" Basic formatting stuff for languages I don't have specific rules for
set softtabstop=4 shiftwidth=4 expandtab autoindent

" Always show filename
set laststatus=2

" Encoding stuff... fun
set encoding=utf-8
set fileencodings=utf-8,latin1,sjis
set fileformats=unix,dos,mac

" No highlighting when searching
set nohlsearch

" + register is system clipboard
set clipboard+=unnamedplus
