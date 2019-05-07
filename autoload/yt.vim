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
let s:v.redirecting  = 0
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

let s:Y = g:yanktools.yank
let s:R = g:yanktools.redir
let s:Z = g:yanktools.zeta
let s:current_stack = g:yanktools.current_stack

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
  elseif s:v.redirecting | call s:R.update_stack()
  else                   | call s:Y.update_stack()
  endif                  | call s:reset_vars()
endfun

fun! s:check_swap()
  " reset swap state if cursor moved after finishing swap
  " s:v.has_changed must be 0 because this must run after on_text_change()
  if s:has_pasted && !s:v.has_changed
        \ && getpos('.') != s:post_paste_pos
    call s:current_stack.reset_offset()
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

  " reset changed state in any case
  let s:v.has_changed = 0

  " restore register after redirection
  if s:v.redirecting          | call s:R.update_stack()     | endif
  if s:v.restoring            | call s:F.restore_register() | endif

  " replace operator: return now to keep repeatabilty
  if yt#replop#paste_replacement() | return s:reset_vars()  | endif

  " autoformat / move cursor, ensure CursorMoved runs
  if s:is_being_formatted()   | execute "keepjumps normal! `[=`]" | endif
  if s:is_moving_at_end()     | execute "keepjumps normal! `]"
  else                        | execute "normal! hl"              | endif

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

  " set current stack
  let s:current_stack = s:Y

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
" Redirect / Cut                                                           {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" The 'cut' argument and the current g:yanktools_use_redirection variable
" will define if the deletion will be redirected or not


function! yt#delete(count, register, redirect)
  let s:register = s:choose_reg(a:register, !a:redirect)
  set opfunc=yt#del_opfunc
  let n = a:count > 1 ? string(a:count) : ''
  return n.'g@'
endfunction

function! yt#del_opfunc(type)
  if !s:VM() | call s:deleting() | endif

  if a:type == 'line' | keepjumps normal! `[V`]
  else                | keepjumps normal! `[v`]
  endif
  execute "normal! \"".s:register."d"
endfunction

function! yt#delete_visual(register, cut)
  let reg = s:choose_reg(a:register, a:cut)
  return "\"" . reg . 'd'
endfunction

function! yt#delete_line(register, count, cut)
  let reg = s:choose_reg(a:register, a:cut)
  if !s:VM()
    call s:deleting()
    let pl = a:cut ? '(CutLine)' : '(RedirectLine)'
    let s:v.plug = [pl, a:count, reg]
  endif
  let n = a:count ? a:count : ''
  call feedkeys('"'.reg.n."dd", 'n')
endfunction




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Redirected paste                                                         {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#paste_redirected_with_key(key, plug, visual, format)
  let s:v.format_this = a:format
  let s:v.has_changed = 1
  let s:has_pasted = 1
  let s:v.plug = [a:plug, v:count, g:yanktools_redirect_register]

  " set current stack
  let s:current_stack = s:R

  " set last_paste_key and remember format_this option (used by swap)
  let s:last_paste_key = a:key
  let s:last_paste_format_this = s:v.format_this

  call s:F.dismiss_preview()
  return '"'.g:yanktools_redirect_register.a:key
endfunction



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Duplicate                                                                {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#duplicate_visual()
  call s:F.store_register()
  return "yP"
endfunction

function! yt#duplicate_lines()
  let s:v.plug = ['(DuplicateLines)', v:count, v:register]
  call s:F.store_register()
  return "yyP`]j^"
endfunction

fun! yt#duplicate(type)
  let s:oldvmode = &virtualedit | set virtualedit=onemore
  call s:F.store_register()
  if a:type == 'line'
    keepjumps normal! `[V`]yP`]j^
  else
    keepjumps normal! `[v`]yP`]
  endif
  let &virtualedit = s:oldvmode
endfun


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Swap paste                                                               {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yt#swap_paste(forward, key)
  if s:current_stack.empty()
    return
  endif

  if !s:has_pasted || ( b:changedtick != s:last_paste_tick )
    " ensure current stack offset is correct
    call s:current_stack.synched()
    execute "normal ".a:key
    return
  endif

  "---------------------------------------------------------------------------

  " enable lazyredraw for better statusline message
  let s:v.lz = &lazyredraw | set lz

  " move stack offset and get return message code
  let msg = s:current_stack.move_offset(a:forward, 1)

  " set register to offset
  call s:current_stack.update_register()

  " set flag before actual paste, so that autocmd call will run
  let s:has_pasted = 1 | let s:v.has_changed = 1

  " perform a non-recursive paste, but reuse last options and key
  let s:v.format_this = s:last_paste_format_this
  exec 'normal! u'.s:last_paste_key

  " update position, because using non recursive paste
  let s:post_paste_pos = getpos('.')

  " restore register (unless stack is frozen)
  if !s:current_stack.frozen
    call s:F.restore_register()
  endif
  call s:F.dismiss_preview()
  call s:msg(msg)
endfunction



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Choose offset                                                            {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! yt#offset(next)
  let S = s:current_stack
  if S.empty()
    return
  endif

  " move stack offset and set register
  call S.move_offset(a:next)
  call S.update_register()

  " show register in preview
  call S.show_current()
endfun



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helper fuctions                                                          {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:is_being_formatted()
  let all = g:yanktools_auto_format_all
  let this = s:v.format_this
  return (all && !this) || (!all && this)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:is_moving_at_end()
  return g:yanktools_move_cursor_after_paste || s:v.move_this
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:msg(n)
  redraw
  echo s:current_stack.name "stack position: " . (s:current_stack.offset + 1)
        \ . "/" . s:current_stack.size()
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
  let s:v.redirecting = 0
  let s:v.restoring = 0
  let s:v.zeta = 0
  let s:v.has_yanked = 0
  let s:v.plug = []
  call s:F.updatetime(1)
endfun

"------------------------------------------------------------------------------

fun! s:choose_reg(reg, cut)
  " Cases: use default, redirect, or a register has been specified?
  " if cutting, we're always use the provided register, even if default
  " otherwise we'll redirect, unless a register has been provided
  let s:v.cutting = g:yanktools_use_redirection && a:cut ||
        \           !g:yanktools_use_redirection && !a:cut
  return s:v.cutting || a:reg != s:F.default_reg() ?
        \ a:reg : g:yanktools_redirect_register
endfun

"------------------------------------------------------------------------------

fun! s:deleting()
  if s:v.cutting
    let s:v.has_changed = 1
    let s:v.has_yanked = 1
  else
    let s:v.has_changed = 1
    let s:v.redirecting = 1
  endif
endfun

"------------------------------------------------------------------------------

fun! s:VM() abort
  return exists('g:Vm') && g:Vm.is_active
endfun


