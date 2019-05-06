fun! yt#funcs#init()
  return s:Funcs
endfun

let s:v = g:yanktools.vars
let s:Funcs = {}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:Funcs.set_repeat() abort
  if get(g:, 'yanktools_repeat', 0) && !empty(s:v.plug) && !s:v.redirecting
    let p = s:v.plug
    silent! call repeat#setreg("\<Plug>".p[0], p[2])
    silent! call repeat#set("\<Plug>".p[0], p[1])
  endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:Funcs.default_reg() abort
  " get default register

  let clipboard_flags = split(&clipboard, ',')
  if index(clipboard_flags, 'unnamedplus') >= 0
    return "+"
  elseif index(clipboard_flags, 'unnamed') >= 0
    return "*"
  else
    return "\""
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:Funcs.get_register(...) dict
  if a:0 || s:v.redirecting
    " don't overwrite stored register because it will be restored
    let r = g:yanktools_redirect_register
    return [r, getreg(r), getregtype(r)]
  else
    " store current register for later restoring, then return it
    let r = self.default_reg()
    let s:v.stored_register = [r, getreg(r), getregtype(r)]
    return s:v.stored_register
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:Funcs.restore_register() dict
  let r = s:v.stored_register
  call setreg(r[0], r[1], r[2])
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:Funcs.updatetime(restore) dict
  if exists("##TextYankPost") | return | endif
  if a:restore
    let &updatetime = s:v.updatetime
  else
    let &updatetime = 100
  endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:Funcs.msg(txt, ...) abort
  exe "echohl" ( !a:0 ? "WarningMsg" : "StorageClass" )
  echo a:txt
  echohl None
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:Funcs.dismiss_preview() abort
  " this will force dismissal of preview window
  let s:v.pwline = -1
endfun


