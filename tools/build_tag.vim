set nocompatible
set nomore
set encoding=utf-8
set fileencodings=utf-8
syntax on
colorscheme delek
let g:html_no_progress = 1

if has('windows') && !has('gui_running')
  set t_ti=
endif

enew!

source <sfile>:h/tag_aliases.vim
source <sfile>:h/untranslated.vim
source <sfile>:h/makehtml.vim

let s:tools_dir = expand('<sfile>:p:h')
let s:proj_dir = expand('<sfile>:p:h:h')

function! s:main()
  " for the lastest help syntax
  let &runtimepath = s:tools_dir . ',' . &runtimepath
  " for ja custom syntax
  let &runtimepath .= ',' . s:proj_dir
  call s:BuildTag()
endfunction

function! s:BuildTag()
  " generate tags
  try
    helptags .
  catch
    echo v:exception
  endtry
  call MakeTagsFile()
endfunction

call s:main()
