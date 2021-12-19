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
  if argc() != 2
    echoerr "require two arguments"
    finish
  endif
  call s:BuildHtml(argv(0), argv(1))
endfunction

function! s:BuildHtml(src, dst)
  call MakeHtml2(a:src, a:dst, 1)
  call s:ToJekyll(a:dst)
endfunction

function! s:ToJekyll(file)
  set nomodeline
  execute "edit! " . a:file
  set fileformat=unix

  let helpname = expand('%:t:r')
  if helpname == 'index'
    let helpname = 'help'
  endif

  " remove header
  silent 1,/^<hr>/delete _
  " remove footer
  silent /^<hr>/,$delete _

  " escape jekyll tags
  silent %s/{\{2,}\|{%/{{ "\0" }}/ge

  " YAML front matter
  call append(0, [
        \ '---',
        \ 'layout: vimdoc',
        \ printf("helpname: '%s'", helpname),
        \ '---',
        \ ])

  update!
endfunction

call s:main()
