"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Initialize                                                               {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:post_paste_pos = getpos('.')
let s:has_pasted = 0
let s:last_paste_format_this = 0
let s:last_paste_key = 0
let s:last_paste_tick = -1

let s:F = g:yanktools.Funcs

let s:v = g:yanktools.vars
let s:v.replacing    = 0
let s:v.restoring    = 0
let s:v.format_this  = 0
let s:v.has_changed  = 0
let s:v.move_this    = 0
let s:v.zeta         = 0
let s:v.has_yanked   = 0
let s:v.updatetime   = &updatetime

let s:Y = g:yanktools.yank
let s:Z = g:yanktools.zeta
let s:A = g:yanktools.auto

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocommand calls                                                        {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#check_yanks()
  """This function is called on TextYankPost.
  if s:VM() && !s:v.zeta | return
  elseif s:v.has_yanked  | call s:update_yanks()
  else                   | call s:A.update_stack()
  endif
endfunction

fun! s:update_yanks()
  if s:v.zeta            | call s:Z.update_stack()
  else                   | call s:Y.update_stack()
  endif
  let s:v.has_yanked = 0
endfun

fun! yt#check_swap()
  " reset swap state if cursor moved after finishing swap
  " s:v.has_changed must be 0 because this must run after on_text_change()
  if s:has_pasted && !s:v.has_changed
        \ && getpos('.') != s:post_paste_pos
    let s:has_pasted = 0
    let s:post_paste_pos = getpos('.')
    let s:last_paste_tick = b:changedtick
  endif
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#on_text_change()
  """This function is called on TextChanged event."""
  if s:v.has_yanked   | call s:update_yanks() | endif
  if !s:v.has_changed | return                | endif
  if s:VM()           | return s:reset_vars() | endif

  " restore register if necessary
  if s:v.restoring | call s:F.restore_register() | endif

  " autoformat / move cursor, and ensure CursorMoved is triggered
  if s:is_being_formatted()   | execute "keepjumps normal! `[=`]" | endif
  if s:is_moving_at_end()     | execute "keepjumps normal! `]"    | endif
  call s:F.ensure_cursor_moved()

  " record position and tick (used by swap)
  let s:last_paste_tick = b:changedtick | let s:post_paste_pos = getpos('.')

  call s:reset_vars()
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Yank/paste                                                               {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#yank_with_key(key)
  if s:VM() | return a:key | endif
  let s:v.has_yanked = 1
  call s:F.updatetime(0)
  return a:key
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#paste_with_key(key, visual)
  if a:visual | call s:F.store_register() | endif

  " set paste variables
  let s:v.has_changed = 1 | let s:has_pasted = 1

  " set last_paste_key and remember format_this option (used by swap)
  let s:last_paste_key = a:key
  let s:last_paste_format_this = 0

  return a:key
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#paste_indent(key)
  " set paste variables
  let s:v.has_changed = 1 | let s:has_pasted = 1

  " set last_paste_key and remember format_this option (used by swap)
  let s:last_paste_key = a:key
  let s:last_paste_format_this = 1

  let s:paste_count = v:count
  let &operatorfunc = 'yt#paste_' . (a:key ==# 'P' ? 'above' : 'below')
  return 'g@^'
endfunction

fun! yt#paste_above(type)
  exe 'normal!' s:paste_count . 'P`[=`]`['
endfun

fun! yt#paste_below(type)
  exe 'normal!' s:paste_count . 'p`[=`]`]'
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#save_current(reg) abort
  if empty(getreg(a:reg))
    return s:F.msg('Register '.a:reg.' is empty!')
  endif
  call s:Y.update_stack(a:reg)
  call s:F.msg('Register '''.a:reg.''' saved', 1)
endfunction




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Delete                                                                   {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#delete(count, register, visual)
  if a:visual
    call s:deleting()
    return "\"" . a:register . 'd'
  endif

  let n = a:count > 1 ? string(a:count) : ''
  let s:register = a:register
  set opfunc=yt#del_opfunc
  return ":\<c-u>\<cr>".n.'g@'
endfunction

function! yt#del_opfunc(type)
  call s:deleting()
  if a:type == 'line' | keepjumps normal! `[V`]
  else                | keepjumps normal! `[v`]
  endif
  execute "normal! \"".s:register."d"
endfunction




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Preserve unnamed register                                                {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" if a register is specified, no change from vim
" otherwise unnamed register (") is restored after change

function! yt#redirect(key, register, save)
  if a:register == s:F.default_reg()
    call s:F.store_register()
    let s:v.has_yanked = a:save
  endif
  return a:key
endfunction



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Swap paste                                                               {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#swap_paste(forward, key)
  if s:Y.is_empty() | return | endif

  " ensure register and stack are synched
  let was_synched = s:Y.synched()

  if !s:has_pasted || ( b:changedtick != s:last_paste_tick )
    execute "normal ".a:key
    return
  endif

  "---------------------------------------------------------------------------

  " enable lazyredraw for better statusline message
  let s:v.lz = &lazyredraw | set lz

  " move stack offset and get return message code
  " if stack wasn't synched, it has been moved already (to the current offset)
  let result = was_synched ? s:Y.move_offset(a:forward ? 1 : -1) : 0

  " set register to offset
  call s:Y.update_register()

  " set flag before actual paste, so that autocmd call will run
  let s:has_pasted = 1 | let s:v.has_changed = 1

  " perform a non-recursive paste, but reuse last options and key
  let s:v.format_this = s:last_paste_format_this
  exec 'normal! u'.s:last_paste_key

  " update position, because using non recursive paste
  let s:post_paste_pos = getpos('.')

  call s:msg(result)
endfunction



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Choose offset                                                            {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" mappings: ]y, [y,

fun! yt#offset(count)
  if s:Y.is_empty() | return | endif

  " move stack offset and set register
  if s:Y.synched()
    call s:Y.move_offset(a:count)
  endif
  call s:Y.update_register()

  " show register in popup or command line
  if !s:F.popup(s:Y)
    echohl Label
    echo printf('[%d/%d] ', s:Y.offset+1, s:Y.size())
    echohl None
    echon split(s:Y.get().text, '\n')[0][:(&columns-10)]
  endif
endfun



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helper fuctions                                                          {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:is_being_formatted()
  let all = g:yanktools_autoindent
  let this = s:v.format_this
  return (all && !this) || (!all && this)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:is_moving_at_end()
  return s:v.move_this
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:msg(n)
  redraw
  echo "Yank stack position: " . (s:Y.offset + 1) . "/" . s:Y.size()
  if a:n
    echohl WarningMsg
    if a:n == 1 | echon " restarting from the beginning"
    else        | echon " restarting from the end"
    endif
    echohl None
  endif
  let &lazyredraw = s:v.lz
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:reset_vars()
  " reset vars
  let s:v.has_changed = 0
  let s:v.replacing = 0
  let s:v.format_this = 0
  let s:v.move_this = 0
  let s:v.restoring = 0
  let s:v.zeta = 0
  let s:v.has_yanked = 0
  call s:F.updatetime(1)
endfun

"------------------------------------------------------------------------------

fun! s:deleting()
  let s:v.has_changed = 1
  let s:v.has_yanked = 1
endfun

"------------------------------------------------------------------------------

fun! s:VM() abort
  return exists('b:visual_multi')
endfun


