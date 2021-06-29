let g:python_host_prog = '/usr/local/bin/python'
let g:python3_host_prog = '/usr/local/bin/python3'

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

" Add `gnatls` and `ada_language_server` to path
let $PATH="/home/BUILD64/bin/gcc-8.3.0-glibc-2.17/bin:" . $PATH
let $PATH="/home/Users/tla/ada_lsp/:" . $PATH
call coc#config("languageserver", {
   \    "als": {
   \        "command": "ada_language_server",
   \        "filetypes": ["ada"],
   \        "settings": {
   \            "ada": {
   \                "projectFile": "/home/PUBLIC/tla/vcast.gpr",
   \                "scenarioVariables": {}
   \            }
   \        }
   \    }
   \})

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
    new
    execute "term " . join(a:000)
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

augroup Term
    autocmd!
    autocmd TermOpen * setlocal nonumber statusline=%#StatusFile#%f%* nohidden scrollback=100000
    autocmd TermOpen * normal! G
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
augroup END

let g:vector_campaign_dir='python/vector/testsuite/test_campaigns/'
function! g:GetLevel()
    let l:path = expand('%:r')
    let l:level = substitute(path, g:vector_campaign_dir, '', '')
    " Not in campaign dir
    if level ==# path
        return ""
    endif
    let l:func_line = search('^    def .*', 'bcnW')
    if func_line > 0
        let l:line = getline(func_line)
        let l:test = substitute(line, '^\s*def \(\%(test\|pre\|post\).*\)(self):\s*$', '\1', '')
        if test !=# line
            let l:level .= "/" . test
        endif
    endif
    return level
endfunction

function! s:VtestComplete(ArgLead, CmdLine, CursorPos)
    let l:args = a:CmdLine
    let l:has_equal_sign = match(l:args, "=") != -1
    if l:has_equal_sign
        let l:args = substitute(l:args, '--level=', '--level ', '')
    endif
    let l:ends_with_space = match(l:args, " $") != -1
    let l:argc = len(split(l:args)) - 1 + (l:ends_with_space ? 1 : 0)
    let l:completions = systemlist("_vtest_complete_args ".l:argc." ".l:args)
    if l:has_equal_sign
        let l:completions = map(l:completions, '"--level=".v:val')
    endif
    return l:completions
endfunction

command! -nargs=+ -complete=customlist,s:VtestComplete Vtest call <SID>Exec('vtest', <f-args>)
nmap <expr> ,v ":Vtest --level " . GetLevel()

function! s:OpenTest(test)
    let l:levels = split(a:test, '/')
    if len(l:levels) < 3
        return
    endif
    execute "split " . systemlist('suite_py ' . a:test)[0]
    if len(l:levels) == 4
        execute "/" . l:levels[-1]
    endif
endfunction
command! -nargs=1 -complete=customlist,s:VtestComplete OpenTest call <SID>OpenTest(<f-args>)

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
set fileencodings=latin1,utf-8,sjis
set fileformats=unix,dos,mac

" No highlighting when searching
set nohlsearch

" + register is system clipboard
set clipboard+=unnamedplus
