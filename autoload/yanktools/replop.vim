""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Replace operator
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! yanktools#replop#paste_replacement()
  if !g:yanktools_is_replacing
    return
  endif
  let g:yanktools_auto_format_this = s:format_this
  execute "normal \"".s:repl_reg."P"
  normal! `]
  let &virtualedit = s:oldvmode
  return g:yanktools_is_replacing == 2
endfun

fun! yanktools#replop#replace(type)
  let reg = get(g:, 'yanktools_replace_operator_bh', 1)
        \ ? "_" : g:yanktools_redirect_register
  let g:yanktools_has_changed = 1
  let g:yanktools_is_replacing = 1 + s:repeatable
  let s:oldvmode = &virtualedit | set virtualedit=onemore
  if a:type == 'line'
    execute "keepjumps normal! `[V`]"
  else
    execute "keepjumps normal! `[v`]"
  endif
  execute "normal! \"".reg."d"
  if !s:repeatable
    let &undolevels = &undolevels
  endif
endfun

fun! yanktools#replop#opts(register, format, repeat)
  " prevent black hole register bug
  let s:repl_reg = a:register == "_" ? yanktools#default_reg() : a:register
  let s:format_this = a:format
  let s:repeatable = a:repeat
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Replace lines
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:del_before_replace(r, c)
  let reg = get(g:, 'yanktools_replace_operator_bh', 1)
        \ ? "_" : g:yanktools_redirect_register

  if getregtype(a:r) ==# 'V'
    for i in range(a:c)
      execute "normal! \"".reg."dd"
    endfor
    let &undolevels = &undolevels
    return
  else
    execute "normal! \"".reg."d$j"
    for i in range(a:c - 1)
      execute "normal! \"".reg."dd"
    endfor
    let &undolevels = &undolevels
    normal! k$l
  endif
endfun

fun! yanktools#replop#replace_line(r, c, multi, format)
  let s:repl_reg = a:r
  let s:oldvmode = &virtualedit | set virtualedit=onemore

  " last line needs 'paste after'
  let paste_type = (line(".") == line("$")) ? "p" : "P"

  " delete lines to replace first
  call s:del_before_replace(a:r, a:c)

  " multiple or single replacement
  let N = a:multi ? range(a:c) : [0]
  for i in N
    let g:yanktools_auto_format_this = a:format
    execute "normal \"".a:r.paste_type
  endfor

  let &virtualedit = s:oldvmode
  let plug = "(ReplaceLine"
        \ . (a:format ? 'Format' : '') . (a:multi ? 'Multi' : 'Single') . ')'
  let g:yanktools_plug = [plug, a:c, a:r]
  call yanktools#set_repeat()
endfun
