""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:v = g:yanktools.vars
let s:F = g:yanktools.Funcs

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#zeta#yank(key)
  let s:v.zeta = 1
  let s:v.has_yanked = 1
  call s:F.updatetime(0)
  return a:key
endfunction

function! yt#zeta#delete(count, register, visual)
  let s:v.zeta = 1
  if a:visual
    let s:v.has_changed = 1
    let s:v.has_yanked = 1
    return "\"" . a:register . 'd'
  endif
  let n = a:count > 1 ? string(a:count) : ''
  let s:register = a:register
  set opfunc=yt#zeta#del_opfunc
  return ":\<c-u>\<cr>".n.'g@'
endfunction

function! yt#zeta#del_opfunc(type)
  let s:v.has_changed = 1
  let s:v.has_yanked = 1
  let s:v.zeta = 1
  if a:type == 'line' | keepjumps normal! `[V`]
  else                | keepjumps normal! `[v`]
  endif
  execute "normal! \"".s:register."d"
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#zeta#paste(key, plug)
  let Z = g:yanktools.zeta
  if Z.is_empty() | return | endif

  " update repeat.vim
  silent! call repeat#setreg("\<Plug>".a:plug, s:F.default_reg())
  silent! call repeat#set("\<Plug>".a:plug, v:count)

  if a:key ==# 'p'
    let s:v.move_this = 1
    let post = ''
  else
    let s:v.move_this = 0
    let post = '`['
  endif

  " backup register
  call s:F.store_register()

  " pop an item from the stack and perform paste
  call Z.pop_stack()
  exec 'normal!' a:key.post

  call s:F.restore_register()
  call s:F.msg("There are " . len(Z.stack) . " entries left in the zeta stack.")
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#zeta#visual_paste()
  let Z = g:yanktools.zeta
  if Z.is_empty() | return | endif

  " backup register
  call s:F.store_register()

  " pop an item from the stack and perform paste
  call Z.pop_stack()
  call s:F.msg("There are " . len(Z.stack) . " entries left in the zeta stack.")
  return 'p'
endfunction

