""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:post_paste_pos = getpos('.')
let s:force_plug = 0
let s:has_pasted = 0
let s:last_paste_format_this = 0
let s:last_paste_key = 0
let s:last_paste_tick = -1

function! yanktools#init_vars()

  if !get(g:, 'yanktools_loaded', 0)
    call yanktools#init#maps()
  endif

  call yanktools#stack#init()
  let s:Y = g:yanktools.yank
  let s:R = g:yanktools.redir
  let s:Z = g:yanktools.zeta
  let s:v = g:yanktools.vars
  let s:F = g:yanktools.Funcs

  let s:current_stack = g:yanktools.current_stack
  let s:v.updatetime = &updatetime
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocommand calls {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#check_yanks()
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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#on_text_change()
  """This function is called on TextChanged event."""
  if exists('g:VM') && g:VM.is_active
    return s:reset_vars()
  endif
  if s:v.has_yanked     | call s:update_yanks() | endif
  if !s:v.has_changed   | return                | endif
  let s:v.has_changed = 0

  " restore register after redirection
  if s:v.redirecting         | call s:R.update_stack()        | endif

  " replace operator: complete replacement
  if yanktools#replop#paste_replacement() | return s:reset_vars() | endif

  " autoformat / move cursor, ensure CursorMoved runs
  if s:is_being_formatted()   | execute "keepjumps normal! `[=`]" | endif
  if s:is_moving_at_end()     | execute "keepjumps normal! `]"
  else                        | execute "normal! hl"              | endif

  " update repeat.vim
  call s:repeat()

  " record position and tick
  let s:last_paste_tick = b:changedtick | let s:post_paste_pos = getpos('.')

  call s:reset_vars()
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Yank/paste {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#yank_with_key(key)
  if exists('g:VM') && g:VM.is_active
    return a:key
  endif
  let s:v.has_yanked = 1
  call s:F.updatetime(0)
  return a:key
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#paste_with_key(key, plug, visual, format)
  if a:visual | call yanktools#redirecting() | endif
  if a:format | let s:v.format_this = 1 | endif

  " set current stack
  let s:current_stack = s:Y

  " set paste variables
  let s:v.has_changed = 1 | let s:has_pasted = 1

  " set repeat.vim plug
  let s:v.plug = [a:plug, v:count1, v:register]

  " set last_paste_key and remember format_this option (used by swap)
  let s:last_paste_key = a:key
  let s:last_paste_format_this = s:v.format_this

  return a:key
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Redirect / Cut {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" The 'cut' argument and the current g:yanktools_use_redirection variable
" will define if the deletion will be redirected or not

function! yanktools#redir_opts(register)
  let s:register = a:register
endfunction

function! yanktools#cut(type)
  let s:register = s:rreg(s:register, 1)
  call yanktools#delete(a:type)
endfunction

function! yanktools#redirect(type)
  let s:register = s:rreg(s:register, 0)
  call yanktools#delete(a:type)
endfunction

function! yanktools#delete(type)
  if !( exists('g:VM') && g:VM.is_active )
    call s:redir_vars()
  endif

  if a:type == 'line' | execute "keepjumps normal! `[V`]"
  else                | execute "keepjumps normal! `[v`]"
  endif
  execute "normal! \"".s:register."d"
endfunction

function! yanktools#delete_visual(register, cut)
  let reg = s:rreg(a:register, a:cut)
  if !( exists('g:VM') && g:VM.is_active )
    call s:redir_vars()
  endif
  return "\"" . reg . 'd'
endfunction

function! yanktools#delete_line(register, count, cut)
  let reg = s:rreg(a:register, a:cut)
  if !( exists('g:VM') && g:VM.is_active )
    call s:redir_vars()
    let pl = a:cut ? '(CutLine)' : '(RedirectLine)'
    let s:v.plug = [pl, a:count, reg]
    let s:force_plug = 1
  endif
  let n = a:count ? a:count : ''
  call feedkeys('"'.reg.n."dd", 'n')
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Redirected paste {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#paste_redirected_with_key(key, plug, visual, format)
  let s:v.format_this = a:format
  let s:v.has_changed = 1
  let s:has_pasted = 1
  let s:v.plug = [a:plug, v:count, g:yanktools_redirect_register]

  " set current stack
  let s:current_stack = s:R

  " set last_paste_key and remember format_this option (used by swap)
  let s:last_paste_key = a:key
  let s:last_paste_format_this = s:v.format_this

  return '"'.g:yanktools_redirect_register.a:key
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! yanktools#restore_after_redirect()
  " don't store empty lines/whitespaces only
  if getreg(s:F.default_reg()) !~ '^[\s\n]*$'
    call s:R.update_stack()
  else
    let r = g:yanktools.redir.stack[0]
    call setreg(g:yanktools_redirect_register, r['text'], r['type'])
  endif
  call setreg(s:r[0], s:r[1], s:r[2])
endfun

fun! yanktools#redirecting()
  " register will be restored in any case, even if specifying a register
  let s:v.has_changed = 1
  let s:v.redirecting = 1
  call s:F.get_register()
endfun


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Duplicate {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#duplicate_visual()
  call yanktools#redirecting()
  return "yP"
endfunction

function! yanktools#duplicate_lines()
  let s:force_plug = 1
  let s:v.plug = ['(DuplicateLines)', v:count, v:register]
  call yanktools#redirecting()
  return "yyP"
endfunction

fun! yanktools#duplicate(type)
  let s:oldvmode = &virtualedit | set virtualedit=onemore
  call yanktools#redirecting()
  if a:type == 'line'
    keepjumps normal! `[V`]yP
  else
    keepjumps normal! `[v`]yP
  endif
  let &virtualedit = s:oldvmode
endfun


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Swap paste {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! yanktools#swap_paste(forward, key)

  if !s:has_pasted || ( b:changedtick != s:last_paste_tick )
    execute "normal ".a:key
    return
  endif

  "---------------------------------------------------------------------------

  " move stack offset and get return message code
  let msg = s:current_stack.move_offset(a:forward)

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
  call s:msg(msg)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helper fuctions {{{1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:is_being_formatted()
  let all = g:yanktools_auto_format_all
  let this = s:v.format_this
  return (all && !this) || (!all && this)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:is_moving_at_end()
  return g:yanktools_move_cursor_after_paste || s:v.move_this
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:msg(n)
  if !a:n
    echo s:current_stack.name "stack position:" s:current_stack.offset + 1
          \ . "/" . s:current_stack.size()
  else
    let t = tolower(s:current_stack.name)
    echohl WarningMsg
    if a:n == 1 | echo "Reached the end of the" t
          \            "stack, restarting from the beginning."
    else        | echo "Reached the beginning of the" t
          \            "stack, restarting from the end."
    endif
    echohl None
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:reset_vars()
  " reset vars
  let s:v.has_changed = 0
  let s:v.is_replacing = 0
  let s:v.format_this = 0
  let s:v.move_this = 0
  let s:v.redirecting = 0
  let s:v.zeta = 0
  let s:v.has_yanked = 0
  let s:v.plug = []
  let s:force_plug = 0
  call s:F.updatetime(1)
endfun

"------------------------------------------------------------------------------

fun! s:repeat()
  " update repeat.vim, duplicating also redirects reg but can be repeated
  if !empty(s:v.plug)
    if !s:v.redirecting || s:force_plug
      call s:F.set_repeat()
    endif
  endif
endfun

"------------------------------------------------------------------------------

fun! s:rreg(reg, cut)
  " redirect, cut, or a register has been specified?
  let s:cutting = g:yanktools_use_redirection && a:cut ||
        \ !a:cut && !g:yanktools_use_redirection
  return s:cutting ? a:reg
        \ : a:reg == s:F.default_reg()
        \ ? g:yanktools_redirect_register : a:reg
endfun

"------------------------------------------------------------------------------

fun! s:redir_vars()
  if s:cutting
    let s:v.has_changed = 1
    let s:v.has_yanked = 1
    let s:cutting = 0
  else
    call yanktools#redirecting()
  endif
endfun


