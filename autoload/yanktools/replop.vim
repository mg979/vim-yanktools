""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Replace operator
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! yanktools#replop#paste_replacement()
  let g:yanktools_is_replacing = 0
  let g:yanktools_auto_format_this = s:format_this
  execute "normal! \"".s:repl_reg."P`]"
  let &virtualedit = s:oldvmode
endfun

fun! yanktools#replop#replace(type)
  let reg = get(g:, 'yanktools_replace_operator_bh', 1)
        \ ? "_" : g:yanktools_redirect_register
  let g:yanktools_has_changed = 1
  let g:yanktools_is_replacing = 1
  let s:oldvmode = &virtualedit | set virtualedit=onemore
  if a:type == 'line'
    exe "keepjumps normal! `[V`]"
    execute "normal! \"".reg."d"
  else
    exe "keepjumps normal! `[v`]"
    execute "normal! \"".reg."d"
  endif
endfun

fun! yanktools#replop#opts(register, format)
  let s:repl_reg = a:register
  let s:format_this = a:format
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Replace lines
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:d_before_replace(r1, r2)
  if getreg(a:r1) !~ '\n'
    execute "normal 0\"".a:r2."d$"
  else
    execute "normal \"".a:r2."dd"
  endif
endfun

fun! yanktools#replop#replace_line(r, c, multi, format)
  let reg = get(g:, 'yanktools_replace_operator_bh', 1)
        \ ? "_" : g:yanktools_redirect_register
  let s:repl_reg = a:r
  let s:oldvmode = &virtualedit | set virtualedit=onemore

  " last line needs 'paste after'
  let paste_type = (line(".") == line("$")) ? "p" : "P"

  " delete lines to replace first
  for i in range(a:c)
    call s:d_before_replace(a:r, reg)
  endfor

  " multiple or single replacement
  let N = a:multi ? range(a:c) : [0]
  for i in N
    let g:yanktools_auto_format_this = a:format
    execute "normal \"".a:r.paste_type
  endfor

  let &virtualedit = s:oldvmode
  let plug = "ReplaceOperatorLine"
        \ . (a:format ? 'Format' : '') . (a:multi ? 'Multi' : 'Single')
  let g:yanktools_plug = [plug, 1, a:r]
  call yanktools#set_repeat()
endfun
