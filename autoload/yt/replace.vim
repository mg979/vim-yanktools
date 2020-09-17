""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Replace operator
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:v = g:yanktools.vars
let s:F = g:yanktools.Funcs

fun! yt#replace#operator(count, register, reindent)
  let s:repl_reg = a:register == "_" ? s:F.default_reg() : a:register
  let s:reindent = a:reindent
  let n = a:count>1? string(a:count) : ''
  let s:repl_count = ''
  set opfunc=yt#replace#opfunc
  return ":\<c-u>\<cr>".n."g@"
endfun

fun! yt#replace#opfunc(type)
  call s:F.store_register(1)
  let oldvmode = &virtualedit
  set virtualedit=onemore
  if a:type == 'line' | keepjumps normal! `[V`]
  else                | keepjumps normal! `[v`]
  endif
  let r = s:reindent ? '`[=`]' : ''
  execute "normal! \"" . s:repl_reg . s:repl_count . "p`]".r
  let &virtualedit = oldvmode
  call s:F.restore_register()
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Replace lines
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! yt#replace#line(count, register, reindent)
  let s:repl_reg = a:register == "_" ? s:F.default_reg() : a:register
  let s:reindent = a:reindent
  let s:repl_count = a:count>1? string(a:count) : ''
  set opfunc=yt#replace#opfunc
  return ":\<c-u>\<cr>".s:repl_count."g@_"
endfun
