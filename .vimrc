call plug#begin('~/.vim/plugged')

Plug 'tylanphear/stanza.vim'
Plug 'tpope/vim-fugitive'

call plug#end()

let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"

function! s:Exec(...) abort
    let l:args = map(copy(a:000), {_, arg -> expand(escape(arg, '\'))})
    exec 'terminal ' . join(l:args)
endfunction
command! -nargs=+ -complete=shellcmd Exec call <SID>Exec(<f-args>)

" Status line highlight groups
hi StatusFunction guibg=darkgreen  cterm=reverse,bold ctermbg=52
hi StatusError    guifg=red        cterm=reverse,bold ctermfg=red    ctermbg=white
hi StatusFile     guibg=darkblue   cterm=reverse,bold ctermbg=21
hi StatusWarning  guifg=yellow     cterm=reverse,bold ctermfg=yellow ctermbg=white

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
    echo map(synstack(line("."), col(".")), {_, val -> val->synIDattr("name")})
endfunction
map <Leader>D :call <SID>PrintSynStack()<CR>

augroup make
" Make needs tabs
    autocmd!
    autocmd FileType make setlocal tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab
augroup Diff
" Highlight trailing space in diffs
    autocmd!
    autocmd FileType diff HighlightSpaces
augroup Ada
    autocmd!
    autocmd FileType ada setlocal tabstop=3 softtabstop=3 shiftwidth=3 expandtab autoindent smarttab
augroup Cpp
    autocmd!
    autocmd FileType c,cpp setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab autoindent smarttab
augroup Python
    autocmd!
    autocmd FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab autoindent smarttab
    autocmd FileType python nnoremap <buffer> <C-H> :split %:r.md<CR>
augroup Markdown
    autocmd!
    autocmd FileType markdown nnoremap <buffer> <C-H> :split %:r.py<CR>
augroup YAML
    autocmd!
    autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab autoindent smarttab
augroup Jinja
    autocmd!
    autocmd BufNewFile,BufRead *.html.template,*.txt.template set ft=jinja
    autocmd FileType jinja setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab autoindent smarttab
augroup Stanza
    autocmd!
    autocmd FileType stanza setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab autoindent smarttab
    autocmd FileType stanza nnoremap <buffer> <silent> K :call FindStanzaEntity()<CR>
    autocmd FileType stanza nmap <buffer> <silent> <C-k> <Plug>(stanza-up-indent)
    autocmd FileType stanza nmap <buffer> <silent> <C-j> <Plug>(stanza-down-indent)
augroup END

command! -nargs=+ -complete=file Rg call <SID>Exec('rg', '--path-separator=//', '--color=always', '--vimgrep', <f-args>)
nnoremap ,r :Rg 

" Convenience commands for my fat fingers
command! -nargs=0 -bang W :w<bang>
command! -nargs=0 -bang Wq :wq<bang>

" Y normally does yy, this makes it consistent with D and C
map Y y$

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

set background=dark
