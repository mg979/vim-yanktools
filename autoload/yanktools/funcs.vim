fun! yanktools#funcs#init()
  return s:Funcs
endfun

let s:v = g:yanktools.vars
let s:Funcs = {}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:Funcs.set_repeat() dict
  if !get(g:, 'yanktools_repeat', 0) | return | endif
  let p = s:v.plug
  silent! call repeat#setreg("\<Plug>".p[0], p[2])
  silent! call repeat#set("\<Plug>".p[0], p[1])
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:Funcs.default_reg() dict
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

function! s:Funcs.set_register(r) dict
  call setreg(a:r[0], a:r[1], a:r[2])
  let s:v.stored_register = [a:r[0], a:r[1], a:r[2]]
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

function! s:Funcs.msg(txt, ...) dict
  exe "echohl" ( !a:0 ? "WarningMsg" : "StorageClass" )
  echo a:txt
  echohl None
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:Funcs.update_reg(stack) dict
  let r = self.get_register()
  let text = a:stack[a:stack.offset]['text']
  let type = a:stack[a:stack.offset]['type']
  call setreg(r[0], text, type)
endfunction


