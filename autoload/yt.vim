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
let s:v.plug         = []
let s:v.move_this    = 0
let s:v.zeta         = 0
let s:v.has_yanked   = 0
let s:v.updatetime   = &updatetime
let s:v.pwline       = 0

let s:v.is_recording = 0
if get(g:, 'yanktools_start_in_record_mode', 0)
  call yt#extras#toggle_recording(1)
endif

let s:Y = g:yanktools.yank
let s:Z = g:yanktools.zeta

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocommand calls                                                        {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#check_yanks()
  """This function is called on CursorMoved/CursorHold/TextYankPost.
  if s:v.has_yanked
    call s:update_yanks()
  endif
  call s:check_swap()
endfunction

fun! s:update_yanks()
  if s:v.zeta            | call s:Z.update_stack()
  else                   | call s:Y.update_stack()
  endif
endfun

fun! s:check_swap()
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
  if s:VM() | return s:reset_vars() | endif

  if s:v.has_yanked     | call s:update_yanks() | endif
  if !s:v.has_changed   | return                | endif

  " restore register if necessary
  if s:v.restoring | call s:F.restore_register() | endif

  " autoformat / move cursor, and ensure CursorMoved is triggered
  if s:is_being_formatted()   | execute "keepjumps normal! `[=`]" | endif
  if s:is_moving_at_end()     | execute "keepjumps normal! `]"    | endif
  call s:F.ensure_cursor_moved()

  " update repeat.vim
  call s:F.set_repeat()

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

function! yt#paste_with_key(key, plug, visual, format)
  if a:visual | call s:F.store_register() | endif
  if a:format | let s:v.format_this = 1   | endif

  " set paste variables
  let s:v.has_changed = 1 | let s:has_pasted = 1

  " set repeat.vim plug
  let s:v.plug = [a:plug, v:count1, v:register]

  " set last_paste_key and remember format_this option (used by swap)
  let s:last_paste_key = a:key
  let s:last_paste_format_this = s:v.format_this

  call s:F.dismiss_preview()
  return a:key
endfunction

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

function! yt#delete_line(count, register)
  call s:deleting()
  return yt#delete(1, a:register).'_'
endfunction




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Redirect                                                                 {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#redirect(key, register)
  let reg = a:register == s:F.default_reg() ? '_' : a:register
  return '"' . reg . a:key
endfunction



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Duplicate                                                                {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#duplicate_visual()
  call s:F.store_register()
  return "yP"
endfunction

function! yt#duplicate_lines(count)
  let s:dupl_count = a:count>1? string(a:count) : ''
  set opfunc=yt#dupl_opfunc
  return ":\<c-u>\<cr>g@_"
endfunction

function! yt#duplicate(count)
  let s:dupl_count = ''
  set opfunc=yt#dupl_opfunc
  return 'g@'
endfunction

fun! yt#dupl_opfunc(type)
  let oldvmode = &virtualedit
  set virtualedit=onemore
  call s:F.store_register()
  let n = s:dupl_count
  if a:type == 'line'
    exe 'keepjumps normal! `[V`]y'.n.'P`]j^'
  else
    exe 'keepjumps normal! `[v`]y'.n.'P`]'
  endif
  let &virtualedit = oldvmode
endfun


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

  " move stack offset and get return message code
  " if stack wasn't synched, it has been moved already (to the current offset)
  let result = was_synched ? s:Y.move_offset(a:forward, 1) : 0

  " set flag before actual paste, so that autocmd call will run
  let s:has_pasted = 1 | let s:v.has_changed = 1

  " perform a non-recursive paste, but reuse last options and key
  let s:v.format_this = s:last_paste_format_this
  exec 'normal! u'.s:last_paste_key

  " update position, because using non recursive paste
  let s:post_paste_pos = getpos('.')

  call s:F.dismiss_preview()
  call s:msg(result)
endfunction



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Choose offset                                                            {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! yt#offset(count)
  if s:Y.is_empty() | return | endif

  " move stack offset and set register
  call s:Y.move_offset(a:count)

  " show register in preview
  call s:Y.show_current()
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
  return g:yanktools_move_after || s:v.move_this
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:msg(n)
  " enable lazyredraw for better statusline message
  let s:v.lz = &lazyredraw | set lz

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
  let s:v.plug = []
  call s:F.updatetime(1)
endfun

"------------------------------------------------------------------------------

fun! s:deleting()
  let s:v.has_changed = 1
  let s:v.has_yanked = 1
endfun

"------------------------------------------------------------------------------

fun! s:VM() abort
  return exists('g:Vm') && g:Vm.is_active
endfun


