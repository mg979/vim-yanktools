"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Duplicate                                                                {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:v = g:yanktools.vars
let s:F = g:yanktools.Funcs

function! yt#duplicate#visual()
  call s:F.store_register()
  return "y`[P`[".mode()."`]"
endfunction

function! yt#duplicate#lines(count)
  set opfunc=yt#duplicate#opfunc
  let s:dupl_count = a:count>1? string(a:count) : ''
  return ":\<c-u>\<cr>g@_"
endfunction

function! yt#duplicate#operator(count)
  let s:dupl_count = ''
  set opfunc=yt#duplicate#opfunc
  return 'g@'
endfunction

fun! yt#duplicate#opfunc(type)
  let oldvmode = &virtualedit
  set virtualedit=onemore
  call s:F.store_register()
  let n = s:dupl_count
  if a:type == 'line'
    exe 'keepjumps normal! `[V`]y'.n.'P`]j^'
  else
    exe 'keepjumps normal! `[v`]y'.n.'P`]l'
  endif
  let &virtualedit = oldvmode
endfun



