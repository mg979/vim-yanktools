""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Replace operator
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" let &undolevels = &undolevels ( is used to break undo from script )

let s:v = g:yanktools.vars
let s:F = g:yanktools.Funcs

fun! yt#replop#paste_replacement()
  if !s:v.is_replacing
    return
  endif
  let s:v.format_this = s:format_this
  execute "normal \"".s:repl_reg."P"
  normal! `]
  let &virtualedit = s:oldvmode
  return s:v.is_replacing == 2
endfun

fun! yt#replop#replace(type)
  let reg = get(g:, 'yanktools_replace_to_bh', 1)
        \ ? "_" : g:yanktools_redirect_register
  let s:v.has_changed = 1
  let s:v.is_replacing = 1 + s:repeatable
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

fun! yt#replop#opts(register, format, repeat)
  " prevent black hole register bug
  let s:repl_reg = a:register == "_" ? s:F.default_reg() : a:register
  let s:format_this = a:format
  let s:repeatable = a:repeat
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Replace lines
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:del_before_replace(r, c)
  let reg = get(g:, 'yanktools_replace_to_bh', 1)
        \ ? "_" : g:yanktools_redirect_register

  if getregtype(a:r) ==# 'V'
    for i in range(a:c)
      execute "normal! \"".reg."dd"
    endfor
    return
  else
    execute "normal! \"".reg."d$j"
    for i in range(a:c - 1)
      execute "normal! \"".reg."dd"
    endfor
    normal! k$l
  endif
endfun

fun! yt#replop#replace_line(r, c, format)
  " get register
  let reg = getreg(a:r)

  " set marks
  exe "noautocmd normal!" a:c.'yy'

  " set register and replace line(s)
  call setreg('"', reg, 'V')
  let s:v.format_this = a:format
  execute "normal! `[V`]p"

  " restore register
  call setreg('"', reg, 'V')
endfun

fun! yt#replop#replace_multi_line(r, c, format)
  let s:repl_reg = a:r
  let s:oldvmode = &virtualedit | set virtualedit=onemore

  " last line needs 'paste after'
  let paste_type = (line(".") == line("$")) ? "p" : "P"

  " delete lines to replace first
  call s:del_before_replace(a:r, a:c)

  " multiple or single replacement
  for i in range(a:c)
    let s:v.format_this = a:format
    execute "normal \"".a:r.paste_type
  endfor

  let &virtualedit = s:oldvmode
  let s:v.plug = ["(ReplaceLineMulti)", a:c, a:r]
  call s:F.set_repeat()
endfun
